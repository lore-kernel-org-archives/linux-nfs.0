From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS client does not report accurate mtime when mtime is 0
Date: Tue, 15 Jun 2004 09:10:02 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16590.12362.453055.998493@cse.unsw.edu.au>
References: <200406141657.i5EGvL812308@rda07.lmcg.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ba0au-0004PT-3g
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 16:10:24 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ba0aq-0005qP-W6
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 16:10:21 -0700
To: Daniel Forrest <forrest@lmcg.wisc.edu>
cc: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Daniel Forrest on Monday June 14
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

On Monday June 14, forrest@lmcg.wisc.edu wrote:
> I am wondering if this is a known bug and what Linux versions are
> affected by it.  Or if it might be a Red Hat only bug.
> 
> I am using utimes() to set the atime/mtime of a file to 0 (i.e. the
> start of the Epoch).
> 
> When I stat this file on the server and on most of my NFS clients the
> atime/mtime are 0, but on some of the clients the atime is reported as
> 0 and the mtime is some other random time (sometimes the current time,
> sometimes a time within the last few hours, but sometimes a time that
> is years ago).  Here is a sample of incorrect times (run at ~11:41):
> 
>     Mon Jun 14 11:40:52 2004 ***
>     Wed Jun  9 23:50:00 2004
>     Tue Jun 17 09:46:31 2003
>     Mon Jun 25 03:14:47 2001
>     Mon Jun 14 11:41:11 2004 ***
>     Mon Jun 14 10:51:48 2004
>     Mon Jun 14 10:33:23 2004
>     Mon Jun 14 10:10:00 2004
>     Mon Jun 14 10:52:11 2004
>     Mon Jun 14 11:23:57 2004
>     Mon Jun 14 11:41:15 2004 ***
>     Mon Jun 14 11:12:52 2004
>     Thu Apr 11 09:25:14 2002
>     Sat Jun 12 19:38:43 2004
>     Mon Jun 14 09:49:52 2004
>     Mon Jun 14 11:31:21 2004
> 
> (The "***" indicates when the mtime equaled the current time.)

I tripped over this about 18 months ago.

The problem happens at in __nfs_refresh_inode in fs/nfs/inode.c
There is a code fragment:

	if (NFS_CACHE_MTIME(inode) != new_mtime) {
		NFS_MTIME_UPDATE(inode) = jiffies;
		NFS_CACHE_MTIME(inode) = new_mtime;
		inode->i_mtime = nfs_time_to_secs(new_mtime);
	}

NFS has just received some attributes for a file from the server.  It
has a fresh "struct inode" and wants to fill in the fields.
In this "struct inode", NFS_CACHE_MTIME is initialised to zero by
alloc_inode (in fs/inode.c). 
As new_mtime is 0, it appears to be the same as
NFS_CACHE_MTIME(inode), and so inode->i_mtime is not updated.
inode->i_mtime is *not* initialised by alloc_inode, and so has
whatever the value was for the last inode to use this piece of memory.

The simplest fix is probably to add:

	inode->i_mtime = 0;

near the top of nfs_read_inode in fs/nfs/inode.c

NeilBrown



-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
