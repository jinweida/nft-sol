import logo from './logo.svg';
import './App.css';
import { 
  mintMax721,
  mintAndSellMax721,
  mintAndAuctionMax721,
  buyNative,
  delist
} from './contract'
import { useEffect } from 'react';

function App() {
  const mint = async () => {
    mintMax721().then(res => {
      console.log(res)
    }).catch(err => {
      console.log(err)
    })
  }
  const mintAndSell = async () => {
    mintAndSellMax721().then(res => {
      console.log(res)
    }).catch(err => {
      console.log(err)
    })
  }
  const mintAndAuctionMax = async () => {
    mintAndAuctionMax721().then(res => {
      console.log(res)
    }).catch(err => {
      console.log(err)
    })
  }
  const buy = async () => {
    buyNative().then(res => {
      console.log(res)
    }).catch(err => {
      console.log(err)
    })
  }
  const deList = async () => {
    delist().then(res => {
      console.log(res)
    }).catch(err => {
      console.dir(err)
    })
  }
  return (
    <div className="App">
      <button onClick={mintMax721}>mintMax721</button>
      <button onClick={mintAndSell}>mintAndSellMax721</button>
      <button onClick={ mintAndAuctionMax }>mintAndAuctionMax721</button>
      <button onClick={ buy }>buyNative</button>
      <button onClick={ deList }>delist</button>
    </div>
  );
}

export default App;
