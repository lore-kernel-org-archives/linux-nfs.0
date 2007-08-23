From: Peter Staubach <staubach@redhat.com>
Subject: Re: mount.nfs: chk_mountpoint()
Date: Thu, 23 Aug 2007 08:50:40 -0400
Message-ID: <46CD82A0.1000408@redhat.com>
References: <46CC884B.1030207@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOC98-0002iS-H3
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 05:50:46 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOC9C-0004CI-MD
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 05:50:51 -0700
In-Reply-To: <46CC884B.1030207@oracle.com>
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

Chuck Lever wrote:
> Hi all-
>
> The recent addition of the chk_mountpoint() function in 
> utils/mount/mount.c in nfs-utils commit 3b55934b has broken a 
> particular behavior of background mounts.
>
> nfs(5) states that, if the "bg" option is specified, "A missing mount 
> point is treated as a timeout, to allow for nested NFS mounts."
>
> If I try mounting an NFS share onto a non-existent directory while 
> using the "bg" option, I now get an immediate failure:
>
>   mount.nfs: mount point /mnt/nothere does not exist
>
> instead of the mount backgrounding itself to wait for /mnt/nothere to 
> show up.  This is because chk_mountpoint() is causing the mount 
> request to fail immediately.
>
> Is the documented bg retry behavior still desirable? 

Isn't this what autofs is for?  To be able to handle hierarchies
of mounts?

    Thanx...

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
