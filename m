From: David Rientjes <rientjes@cs.washington.edu>
Subject: Re: [PATCH] NFS: nfsaclsvc_encode_getaclres() - Fix potential
 NULL deref and tiny optimization.
Date: Fri, 27 Oct 2006 14:46:03 -0700 (PDT)
Message-ID: <Pine.LNX.4.64N.0610271443500.31179@attu2.cs.washington.edu>
References: <200610272316.47089.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Neil Brown <neilb@cse.unsw.edu.au>,
	Andreas Gruenbacher <agruen@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GdZWr-0001w4-97
	for nfs@lists.sourceforge.net; Fri, 27 Oct 2006 14:46:17 -0700
Received: from mx1.cs.washington.edu ([128.208.5.52])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GdZWr-00044o-6R
	for nfs@lists.sourceforge.net; Fri, 27 Oct 2006 14:46:18 -0700
To: Jesper Juhl <jesper.juhl@gmail.com>
In-Reply-To: <200610272316.47089.jesper.juhl@gmail.com>
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

On Fri, 27 Oct 2006, Jesper Juhl wrote:

> In fs/nfsd/nfs2acl.c::nfsaclsvc_encode_getaclres() I see a few issues.
> 
> 1) At the top of the function we assign to the 'inode' variable by 
> dereferencing 'dentry', but further down we test 'dentry' for NULL. So, if 
> 'dentry' (which is really 'resp->fh.fh_dentry') can be NULL, then either 
> we have a potential NULL pointer deref bug or we have a superflous test.
> 

resp->fh.fh_dentry cannot be NULL on nfsaclsvc_encode_getaclres so the 
early assignment is appropriate for both *dentry and *inode.  *inode will 
need to be checked for NULL in the conditional, however, and return 0 on 
true.

> 3) There are two locations in the function where we may return before we 
> use the value of the variable 'w', but we compute it at the very top of the 
> function. So in the case where we return early we have wasted a few cycles 
> computing a value that was never used.
> 

w should be an unsigned int.

		David

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
