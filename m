From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: dentry/inode cache invalidation when using nfsd filesystem on 2.6
Date: Thu, 23 Oct 2003 13:57:50 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16279.20926.488909.525633@notabene.cse.unsw.edu.au>
References: <20031021142414.GW1516@dbz.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ADSKh-0001Hk-00
	for <nfs@lists.sourceforge.net>; Sat, 25 Oct 2003 10:36:11 -0700
Received: from panoramix.vasoftware.com
	([198.186.202.147] helo=externalmx.vasoftware.com ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1ACxEX-0003kQ-Os
	for nfs@lists.sourceforge.net; Fri, 24 Oct 2003 01:23:45 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24]:38013)
	by externalmx.vasoftware.com with smtp (Exim 4.22 #1 (Debian))
	id 1ACWdq-0007ll-JQ
	for <nfs@lists.sourceforge.net>; Wed, 22 Oct 2003 21:00:06 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <jrsantos@austin.ibm.com>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Thu, 23 Oct 2003 13:57:51 +1000
To: "Jose R. Santos" <jrsantos@austin.ibm.com>
In-Reply-To: message from Jose R. Santos on Tuesday October 21
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

On Tuesday October 21, jrsantos@austin.ibm.com wrote:
> Hi,
> 
> I have come across a interesting behavior when using NFS server on machines
> with large amounts of memory(16/32Gb).  If I have exported filesystems with
> lots of data and many directories that were access and had dentry/inode cache
> entries cached on the server, the clients took a long time(sometimes minutes)
> to mount the NFS exported directories.
> 
> While the client was mostly IDLE, the servers rpc.mountd thread was consuming
> 100% of one CPU on the system.  After some digging, I found that the problem
> lies on the new nfsd filesystem code that talks to nfsctl.  Every time I issue
> a mount on the client, the server invalidates both inode and dentry caches.
> 
> Inode cache get invalidated on sys_nfsservctl(fs/nfsctl.c) on the fput call
> which eventually calls invalidate_inodes. Dentry caches get invalidated on
> do_open(fs/nfsctl.c) when calling do_kernel_mount which eventually calls
> shrink_dcache_sb.
> 
> The inode cache invalidation is easy to work around by just mounting the nfsd
> to something like /tmp/nfsd, but I haven't been able(except with a very
> dangerous and stupid patch) to work around the dentry cache invalidation.
> 
> This invalidation seem unnecessary and it cause by the interaction with this
> new interface for nfsctl.
> 
> Any help would be appreciated. :)
> 
> Thanks - JRS

The problem is NOT that the inode or dentry caches are being flushed.

The problem is that the inode and dentry caches *for*the*(tiny)*nfsd*filesystem*
are being flushed, and this requires iterating through each cache under a
spinlock, and this can take a while.

Basically, "mount" and "unmount" are slow operations.

As you note, "unmount" can be avoided by mounting the nfsd filesystem
somewhere.  I recommend /proc/fs/nfsd.
The "mount" can be avoided by not using the nfsservctl systemcall at all. 
This is achived by mounting nfsd at /proc/fs/nfsd, and running the latest
release of nfs-utils.

*fixing* the problem requires optimising the mount and unmount process,
which is SEP  (Somebody Elses Problem).

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: The SF.net Donation Program.
Do you like what SourceForge.net is doing for the Open
Source Community?  Make a contribution, and help us add new
features and functionality. Click here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
