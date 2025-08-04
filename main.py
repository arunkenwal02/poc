from fastapi import FastAPI

app = FastAPI(
    title='Code validator POC', 
    summary= 'To validate the code'
)


@app.post('/fetchpushhistory')
def fetch_last_two_push(url:str):
    return url