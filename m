From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Wed, 23 Oct 2002 12:53:04 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021023.125304.28780747.taka@valinux.co.jp>
References: <15786.23306.84580.323313@notabene.cse.unsw.edu.au>
	<20021018.221103.35656279.taka@valinux.co.jp>
	<15797.63730.223181.75888@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184Cgz-0000UI-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 21:00:26 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: <15797.63730.223181.75888@notabene.cse.unsw.edu.au>
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

Hello,

> > I've ported the zerocopy patches against linux-2.5.43 with
> > davem's udp-sendfile patches and your patches which you posted
> > on Wed,16 Oct.
> 
> Thanks for these...
> 
> I have been thinking some more about this, trying to understand the
> big picture, and I'm afraid that I think I want some more changes.
> 
> In particular, I think it would be good to use 'struct xdr_buf' from
> sunrpc/xdr.h instead of svc_buf.  This is what the nfs client uses and
> we could share some of the infrastructure.

It sounds good that they share the same infrastructure.
I agree with your approach. 

> I think this would work quite well for sending read responses as there
> is a 'head' iovec for the interesting bits of the packet, an array of
> pages for the data, and a 'tail' iovec for the padding.

I'm wondering one point that the xdr_buf can't hanldle NFSv4 compound
operation correctly yet. I don't know what will happen if we send some
page data and some non-page data together as it will try to pack some
operations in one xdr_buf.

If we care about NFSv4 it could be like this:

    struct svc_buf {
        u32 *                   area;   /* allocated memory */
        u32 *                   base;   /* base of RPC datagram */
        int                     buflen; /* total length of buffer */
        u32 *                   buf;    /* read/write pointer */
        int                     len;    /* current end of buffer */

        struct xdr_buf iov[I_HAVE_NO_IDEA_HOW_MANY_IOVs_NFSV4_REQUIRES];
        int                     nriov;
    }

I guess it would be better to fix NFSv4 problems after Halloween.

> I'm not certain about receiving write requests.
> I imagine that it might work to:
>   1/ call xdr_partial_copy_from_skb to just copy the first 1K from the
>     skb into the head iovec, and hold onto the skbuf (like we
>     currently do).
>   2/ enter the nfs server to parse that header.
>   3/ When the server finds it needs more data for a write, it
>      collects the pages and calls xdr_partial_copy_from_skb
>      to copy the rest of the skb directly into the page cache.

I think it will be hard work that it's the same that we make another
generic_file_write function. I feel it may be overkill.
  e.g. We must read a page if it isn't on the cache.
       We must allocate disk blocks if the file don't have yet X-(
       Some filesytems like XFS have its own way of updating pagecache.

We should make kNFSd keep away from the implementation of VM/FS
as possible as we can.

> Does that make any sense?
> 
> Also, I am wondering about the way that you put zero-copy support into
> nfsd_readdir.
> 
> Presumably the gain is that sock_sendmsg does a copy into a
> skbuf and then a DMA out of that, while ->sendpage does just the DMA.
> In that case, maybe it would be better to get "struct page *" pointers
> for the pages in the default buffer, and pass them to 
> ->sendpage.

It seems good idea.

The problem is that it's hard to know when the page will be released.
The page will be held by TCP/IP stack. TCP may hold it for a while
by way of retransmition. UDP pakcets may also held in driver-queue
after ->sendpage has done.

We should check reference count of the default buffer and 
decide to use the buffer or allocate new one.
We think Almost request can use the default buffer.

> I would like to get the a situation where we don't need to do a 64K
> kmalloc for each server, but can work entirely with individual pages.
> 
> I might try converting svcsock etc to use xdr_buf later today or
> tomorrow unless I heard a good reason why it wont work, or someone
> else beats me to it...

If you don't mind I'll do about the readdir stuff
while you're fighting with the xdr_buf stuffs.

Thank you,
Hirokazu Takahashi


-------------------------------------------------------
This sf.net emial is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ad.doubleclick.net/clk;4699841;7576301;v?http://www.sun.com/javavote
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
