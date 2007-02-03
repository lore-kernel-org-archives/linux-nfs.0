From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/14] locks: factor out generic/filesystem switch
	from test_lock
Date: Sat, 3 Feb 2007 08:50:25 +0000
Message-ID: <20070203085025.GB18828@infradead.org>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
	<5cdd83858bf5c75e14742bbd03b462f5ec4997fe.1170479265.git.bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDGbN-0004Tm-DY
	for nfs@lists.sourceforge.net; Sat, 03 Feb 2007 00:50:29 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HDGbP-00078t-4S
	for nfs@lists.sourceforge.net; Sat, 03 Feb 2007 00:50:31 -0800
In-Reply-To: <5cdd83858bf5c75e14742bbd03b462f5ec4997fe.1170479265.git.bfields@citi.umich.edu>
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

> +int vfs_test_lock(struct file *filp, struct file_lock *fl, struct file_lock *conf)

Please make sure to add linebreaks after at most 80 characters.

> +	error = vfs_test_lock(filp, &file_lock, &cfl);
> +	if (error)
> +		goto out;

> +	fl = (cfl.fl_type == F_UNLCK ? NULL : &cfl);
>  	flock.l_type = F_UNLCK;
>  	if (fl != NULL) {

This code snippled is more than ugly.  fl is only checked for equality
once so you should reformulate that check using the actual type check:

	if (cfl.fl_type != F_UNLCK) {

That also allows you to move the

	flock.l_type = fl->fl_type;

out of the if statement later on.  In fact that copying out should
proably move into posix_lock_to_flock and posix_lock_to_fock64
helpers similar to the flock_to_posix_lock and flock64_to_posix_lock
helpers we have for the other way around.


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
