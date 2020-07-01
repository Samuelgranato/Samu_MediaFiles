from flask import Flask
from flask import render_template
from flask import request
import glob
import os
import urllib
import json

app = Flask(__name__)
 


locations = {
    'naruto' : 'static/Naruto Shippuden Completo (720p) LEGENDADO - WWW.BLUDV.TV/',
    'gotham' : 'static/gotham_test/'
}


def get_files(folder):
    location = locations[folder.lower()]
    files = [os.path.basename(x) for x in glob.glob(location+'*') if '.vtt' not in x]
    files.sort()
    return files


def last_info():
    info = json.load(open("info"))
    return {'folder' : info['folder'], 'episode' : info['episode']}

def write_info(info):
    json.dump(info, open("info",'w'))

def all_folders():
    return ['Naruto', 'Gotham']

@app.route('/')
def home():
    info = last_info()
    folders = all_folders()
    return render_template('home.html',folders = folders, last_folder = info['folder'], last_episode=info['episode'])


@app.route('/folder')
def folder():
    folder = request.args.get('folder')
    files = get_files(folder)
    
    return render_template('folder.html', folder=folder, files=files)

@app.route('/play', methods=["GET", "POST"])
def play():
    folder = request.args.get('folder')
    episode = request.args.get('episode')
    files = get_files(folder)
    i = files.index(episode)
    if request.method == 'POST':
        episode = files[i+1]

    src = locations[folder.lower()] + episode  
    src = urllib.parse.quote(src)

    extension = os.path.splitext(episode)[1]
    src_sub = src.replace(extension,'.vtt')
    write_info({'folder' : folder, 'episode' : episode})

    print(src_sub)
    return render_template('play.html', folder=folder, episode=episode, src=src, src_sub = src_sub)



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)