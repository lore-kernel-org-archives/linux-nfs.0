From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.43
Date: Mon, 28 Oct 2002 17:31:41 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15805.26221.530836.279218@charged.uio.no>
References: <20021024.065015.74750854.taka@valinux.co.jp>
	<15799.14062.275890.83768@charged.uio.no>
	<20021024.103349.26272209.taka@valinux.co.jp>
	<20021027.193917.78705070.taka@valinux.co.jp>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186Co2-00029L-00
	for <nfs@lists.sourceforge.net>; Mon, 28 Oct 2002 08:31:58 -0800
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20021027.193917.78705070.taka@valinux.co.jp>
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

>>>>> " " == Hirokazu Takahashi <taka@valinux.co.jp> writes:

     > --- linux/net/sunrpc/xdr.c.ORG Sat Oct 26 21:21:16 2030
     > +++ linux/net/sunrpc/xdr.c Sun Oct 27 19:07:05 2030
     > @@ -110,12 +110,15 @@ xdr_encode_pages(struct xdr_buf *xdr, st
    xdr-> page_len = len;
 
     >  	if (len & 3) {
     > -		struct iovec *iov = xdr->tail;
     >  		unsigned int pad = 4 - (len & 3);
     > -
     > - iov->iov_base = (void *) "\0\0\0";
     > - iov->iov_len = pad;
     >  		len += pad;
     > + if (((base + len) & ~PAGE_CACHE_MASK) + pad <=
     >  		PAGE_CACHE_SIZE) {
     > + xdr->page_len += pad;

No!!! I believe I told you quite explicitly earlier:

 - RFC1832 states that *all* variable length data must be padded with
   zeros, and that is certainly not the case if the pages you are
   pointing to are in the page cache.

 - Worse: That data is not even guaranteed to have been initialized.
   In effect this means that your 'optimization' is leaking random
   data from the kernel and onto the internet. In security-conscious
   circles this is not considered a good thing...

Please leave that padding so that it *always* returns zeros...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
