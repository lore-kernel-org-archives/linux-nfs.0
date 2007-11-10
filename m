From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs exports & bind mounts
Date: Sat, 10 Nov 2007 17:29:56 -0500
Message-ID: <1194733796.15122.27.camel@heimdal.trondhjem.org>
References: <2077779951@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS@lists.sourceforge.net
To: devzero@web.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IqymS-00007z-CD
	for nfs@lists.sourceforge.net; Sat, 10 Nov 2007 14:26:21 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IqymX-000070-TQ
	for nfs@lists.sourceforge.net; Sat, 10 Nov 2007 14:26:26 -0800
In-Reply-To: <2077779951@web.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


On Sat, 2007-11-10 at 22:36 +0100, devzero@web.de wrote:
> Hi !
> 
> i think everybody knows bind mounts.
> 
> i can do:
> 
> touch /otherpath/dummyfile
> mount -bind /path/file /otherpath/dummyfile
> 
> so /path/file becomes accessible via /otherpath/dummyfile - dummyfile has the same size as file after successful bind-mount
> 
> i can loopback-mount /otherpath/dummyfile to /otherpath/mnt if file/dummyfile contains a filesystem
> 
> when i export /otherpath via nfs (crossmnt), from the client side i can access the contents of the filesystem inside file/dummyfile via /otherpath/mnt  - but i cannot access the contents of dummyfile itself, i.e. the bind-mount seems to get lost on export.
> 
> can someone tell if this is expected behaviour or if this is a bug ?

The NFS client will not cross a mount point unless the target is a
directory. That is not a bug, it is expected behaviour.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
