From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Wed, 23 Oct 2002 11:18:42 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15797.63730.223181.75888@notabene.cse.unsw.edu.au>
References: <20020918.171431.24608688.taka@valinux.co.jp>
	<15786.23306.84580.323313@notabene.cse.unsw.edu.au>
	<20021018.221103.35656279.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184AAj-0000n6-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 18:18:57 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Wed, 23 Oct 2002 11:18:41 +1000
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Friday October 18
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday October 18, taka@valinux.co.jp wrote:
> Hello,
> 
> I've ported the zerocopy patches against linux-2.5.43 with
> davem's udp-sendfile patches and your patches which you posted
> on Wed,16 Oct.

Thanks for these...

I have been thinking some more about this, trying to understand the
big picture, and I'm afraid that I think I want some more changes.

In particular, I think it would be good to use 'struct xdr_buf' from
sunrpc/xdr.h instead of svc_buf.  This is what the nfs client uses and
we could share some of the infrastructure.

I think this would work quite well for sending read responses as there
is a 'head' iovec for the interesting bits of the packet, an array of
pages for the data, and a 'tail' iovec for the padding.

I'm not certain about receiving write requests.
I imagine that it might work to:
  1/ call xdr_partial_copy_from_skb to just copy the first 1K from the
    skb into the head iovec, and hold onto the skbuf (like we
    currently do).
  2/ enter the nfs server to parse that header.
  3/ When the server finds it needs more data for a write, it
     collects the pages and calls xdr_partial_copy_from_skb
     to copy the rest of the skb directly into the page cache.

Does that make any sense?

Also, I am wondering about the way that you put zero-copy support into
nfsd_readdir.

Presumably the gain is that sock_sendmsg does a copy into a
skbuf and then a DMA out of that, while ->sendpage does just the DMA.
In that case, maybe it would be better to get "struct page *" pointers
for the pages in the default buffer, and pass them to 
->sendpage.


I would like to get the a situation where we don't need to do a 64K
kmalloc for each server, but can work entirely with individual pages.

I might try converting svcsock etc to use xdr_buf later today or
tomorrow unless I heard a good reason why it wont work, or someone
else beats me to it...

NeilBrown


-------------------------------------------------------
This sf.net emial is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ad.doubleclick.net/clk;4699841;7576301;v?http://www.sun.com/javavote
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
