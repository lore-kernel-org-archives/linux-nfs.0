From: Neil Brown <neilb@suse.de>
Subject: Re: SUNRPC: Lack of RPC record fragments
Date: Tue, 5 Sep 2006 09:31:33 +1000
Message-ID: <17660.46933.187475.92083@cse.unsw.edu.au>
References: <44FC5F77.9010708@informatik.uni-oldenburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKNuo-0001iR-WF
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:31:43 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GKNus-0000EG-CC
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:31:46 -0700
To: Andre van Hoorn <andre.van.hoorn@informatik.uni-oldenburg.de>
In-Reply-To: message from Andre van Hoorn on Monday September 4
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Monday September 4, andre.van.hoorn@informatik.uni-oldenburg.de wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Hi,
> 
> 
> I'm communicating with the linux NFS kernel server via RPC using the
> sunrpc implementation in glibc. On certain RPC record sizes, glibc
> starts to use record fragmentation (whereas the sunrpc kernel client
> doesn't) and the sunrpc linux kernel server implementation lacks the RPC
> record "defragmentation" functionality as can be seen in
> net/sunrpc/svcsock.c:
> 
> svsk->sk_reclen = ntohl(svsk->sk_reclen);
> if (!(svsk->sk_reclen & 0x80000000)) {
>   /* FIXME: technically, a record can be fragmented,
>    *  and non-terminal fragments will not have the top
>    *  bit set in the fragment length header.
>    *  But apparently no known nfs clients send fragmented
>    *  records. */
>    printk(KERN_NOTICE "RPC: bad TCP reclen 0x%08lx (non-terminal)\n",
>          (unsigned long) svsk->sk_reclen);
>    goto err_delete;
> }
> 
> Unfortunately, I didn't find a way to disable the use of fragmentation
> in glibc. Is there an existing patch for the kernel to support
> fragmented records?

Not that I am aware of, and it would be fairly non-trivial to
implement, for relatively little gain.

You should be able to avoid fragmentation with glibc by setting
'sendsz' large enough.
When you call clnttcp_create, pass a big number for the 5th arg.

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
