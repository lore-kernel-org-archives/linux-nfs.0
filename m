Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43273 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752744Ab1EPUVE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 May 2011 16:21:04 -0400
Date: Mon, 16 May 2011 16:20:59 -0400
From: "Dr. J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Harry Edmon <harry@uw.edu>, Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org
Subject: Re: 2.6.38.6 - state manager constantly respawns
Message-ID: <20110516202059.GC1680@fieldses.org>
References: <4DD16FA8.4030602@uw.edu>
 <05D08339-888C-4A64-BDC5-8667B3901E7A@oracle.com>
 <4DD1772E.9010609@uw.edu>
 <6A6FB1C3-D4C3-40BE-810A-B4551FA9E591@oracle.com>
 <4DD17CB5.7010009@uw.edu>
 <1305575007.19725.3.camel@lade.trondhjem.org>
 <4DD17F79.305@uw.edu>
 <1305575656.19725.9.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1305575656.19725.9.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 16, 2011 at 03:54:16PM -0400, Trond Myklebust wrote:
> On Mon, 2011-05-16 at 12:48 -0700, Harry Edmon wrote:
> > On 05/16/11 12:43, Trond Myklebust wrote:
> > > On Mon, 2011-05-16 at 12:36 -0700, Harry Edmon wrote:
> > >    
> > >> On 05/16/11 12:22, Chuck Lever wrote:
> > >>      
> > >>> On May 16, 2011, at 3:12 PM, Harry Edmon wrote:
> > >>>
> > >>>
> > >>>        
> > >>>> Attached is 1000 lines of output from tshark when the problem is occurring.   The client and server are connected by a private ethernet.
> > >>>>
> > >>>>          
> > >>> Disappointing: tshark is not telling us the return codes.  However, I see "PUTFH;READ" then "RENEW" in a loop, which indicates the state manager thread is being kicked off because of ongoing difficulties with state recovery.  Is there a stuck application on that client?
> > >>>
> > >>> Try again with "tshark -V".
> > >>>
> > >>>        
> > >> Here is the output from tshark -V (first 50,000 lines).   Nothing
> > >> appears to be stuck, and as I said when I reboot the client into 2.6.32
> > >> the problem goes away, only to reappear when I reboot it back into 2.6.38.6.
> > >>
> > >>      
> > > Possibly, but it definitely indicates a server bug. What kind of server
> > > are you using?
> > >
> > > Basically, the client is getting confused because when it sends a READ,
> > > the server is telling it that the lease has expired, then when it sends
> > > a RENEW, the same server replies that the lease is OK...
> > >
> > > Trond
> > >    
> > The server is running the 2.6.38.6 kernel with Debian squeeze, just like 
> > the client.   The kernel config is attached.
> 
> Bruce, any idea how the server might get into this state?

So READ is getting ESTALE and RENEW is getting OK?  And we're positive
that the stateid on the READ is derived from the clientid sent with the
RENEW?

OK, I'll look at the capture....

--b.
