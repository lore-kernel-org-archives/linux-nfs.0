From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Wed, 23 Oct 2002 16:10:37 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15798.15709.589542.122490@notabene.cse.unsw.edu.au>
References: <15786.23306.84580.323313@notabene.cse.unsw.edu.au>
	<20021018.221103.35656279.taka@valinux.co.jp>
	<15797.63730.223181.75888@notabene.cse.unsw.edu.au>
	<20021023.125304.28780747.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184EjG-0004ZL-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 23:10:54 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <neilb@cse.unsw.edu.au>)
	(for <nfs@lists.sourceforge.net>) (for <andros@citi.umich.edu>)
	(for <trond.myklebust@fys.uio.no>) By tone With Smtp ;
	Wed, 23 Oct 2002 16:10:38 +1000
To: Hirokazu Takahashi <taka@valinux.co.jp>
cc: "William A.(Andy) Adamson" <andros@citi.umich.edu>,  trond.myklebust@fys.uio.no
In-Reply-To: message from Hirokazu Takahashi on Wednesday October 23
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

On Wednesday October 23, taka@valinux.co.jp wrote:
> 
> I'm wondering one point that the xdr_buf can't hanldle NFSv4 compound
> operation correctly yet. I don't know what will happen if we send some
> page data and some non-page data together as it will try to pack some
> operations in one xdr_buf.
> 
> If we care about NFSv4 it could be like this:
> 
>     struct svc_buf {
>         u32 *                   area;   /* allocated memory */
>         u32 *                   base;   /* base of RPC datagram */
>         int                     buflen; /* total length of buffer */
>         u32 *                   buf;    /* read/write pointer */
>         int                     len;    /* current end of buffer */
> 
>         struct xdr_buf iov[I_HAVE_NO_IDEA_HOW_MANY_IOVs_NFSV4_REQUIRES];
>         int                     nriov;
>     }
> 
> I guess it would be better to fix NFSv4 problems after Halloween.
> 

Hmm. I wonder what plans there are for this w.r.t. to NFSv4 client.
Andy? Trond?

I suspect that COMPOUNDS with multiple READ or WRITE requests would be
fairly rare, and it would probably be reasonable to respond with
ERESOURCE (or however it is spelt).

i.e. Reject any operation that would need to use a second set of pages
in a response.


> > I'm not certain about receiving write requests.
> > I imagine that it might work to:
> >   1/ call xdr_partial_copy_from_skb to just copy the first 1K from the
> >     skb into the head iovec, and hold onto the skbuf (like we
> >     currently do).
> >   2/ enter the nfs server to parse that header.
> >   3/ When the server finds it needs more data for a write, it
> >      collects the pages and calls xdr_partial_copy_from_skb
> >      to copy the rest of the skb directly into the page cache.
> 
> I think it will be hard work that it's the same that we make another
> generic_file_write function. I feel it may be overkill.
>   e.g. We must read a page if it isn't on the cache.
>        We must allocate disk blocks if the file don't have yet X-(
>        Some filesytems like XFS have its own way of updating pagecache.
> 
> We should make kNFSd keep away from the implementation of VM/FS
> as possible as we can.

Could we not use 'mmap'?   Maybe not, and probably best to avoid it as
you say.

I was thinking it would be nice to be able to do the udp-checksum at
the same time as the copy-into-page-cache, but maybe we just say that
you need a NIC that does checksums if you want to do single-copy NFS
writes. 

NeilBrown


-------------------------------------------------------
This sf.net emial is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
