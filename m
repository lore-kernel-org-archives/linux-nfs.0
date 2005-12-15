From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH]: NFS: fix inadvertent reversion of mode bits
	during chown
Date: Thu, 15 Dec 2005 09:14:47 -0500
Message-ID: <1134656087.7954.7.camel@lade.trondhjem.org>
References: <20051215130939.GA8111@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, neilb@cse.unsw.edu.au,
	linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Emtt3-0001dN-5w
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 06:15:13 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Emtt2-0005NE-EG
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 06:15:13 -0800
To: Neil Horman <nhorman@tuxdriver.com>
In-Reply-To: <20051215130939.GA8111@hmsreliant.homelinux.net>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, 2005-12-15 at 08:09 -0500, Neil Horman wrote:
> Hey all-
> 	This problem was reported to me recently that when a process is attempting
> to change ownership (chown) on a file on a NFS share, it is possible that
> permissions bits will be reverted to a previous state on the server, even if an
> exclusive lock is held on the file.  I verified this, and came to find that this
> occurs if the SUID bit is set on the file.  Basically when a file is chown-ed,
> the chown_call forcibly strips the SUID/SGID bits from the mode (ostensibly for
> security purposes).  The VFS then implements this stripping (if the SUID/SGID
> bits are currently set on the inode in question) by updating the iattr structure
> in notify_change to not only change the UID/GID of the inode, but also the MODE,
> using the mode bits in the inode.  This works fine on locally mounted file
> systems, in which the inodes in ram are only modified by one system, and are in
> sync with disk contents.  However on NFS, its possible for the a files
> attributes to be out of sync with the cached inode on a given system sharing the
> NFS mount.  As such, if system A changes the mode bits on a file on the server,
> system B preforming a chown on an inode cached locally can inadvertantly revert
> permissions on the inode to whatever was most recently cached.
> 
> I don't think this hole can be 100% closed, as we can guarantee the order of
> arival of packets to the server between nodes, but we can be sure that the
> filesystem bits aren't reverted if the accessing programs participate in a
> locking protocol.  The patch below refreshes the inode and strips the SUID/SGID
> bits from the latest server side inode->i_mode bits.  This has been tested and
> prevents the described problem from occuring.
> 
> An alternate solution (and one that generates less traffic) may be to simply
> disallow the setting of ATTR_MODE and (ATTR_UID|ATTR_GID) at the same time in
> nfs_setattr, but I haven't thought through what all the implications are there.

Third alternative: Fix the VFS to not do that. That makes the whole
thing race-free.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
