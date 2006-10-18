From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 10/10] SUNRPC: skb_read_bits is the same
	as	xs_tcp_copy_data
Date: Wed, 18 Oct 2006 17:32:40 -0400
Message-ID: <1161207160.6095.181.camel@lade.trondhjem.org>
References: <20061017184142.25704.44260.stgit@schiele.dsl.sfldmi.ameritech.net>
	<20061017184446.25704.68116.stgit@schiele.dsl.sfldmi.ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GaJ1x-0001Aw-3g
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 14:32:53 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GaJ1x-00069f-9v
	for nfs@lists.sourceforge.net; Wed, 18 Oct 2006 14:32:54 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20061017184446.25704.68116.stgit@schiele.dsl.sfldmi.ameritech.net>
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

On Tue, 2006-10-17 at 14:44 -0400, Chuck Lever wrote:
> Clean-up: eliminate xs_tcp_copy_data -- it's exactly the same logic as the
> common routine skb_read_bits.  The UDP and TCP socket read code now share
> the same routine for copying data into an xdr_buf.
> 
> Also, rename skb_read_bits() since it is now a public function, and rename
> skb_read_and_csum_bits() to be consistent.

This cleanup doesn't appear to depend directly on anything in the
previous 9 patches, but I can't apply it due to the 'private' code
changes.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
