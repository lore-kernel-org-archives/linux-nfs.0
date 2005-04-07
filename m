From: Vasiliy Boulytchev <vasiliy@lohankin.com>
Subject: Re: NFS experince story, questions.
Date: Thu, 07 Apr 2005 15:23:50 -0600
Message-ID: <1112909031.6230.11.camel@vasiliy.coinfotech.com>
References: <1112894081.6230.9.camel@vasiliy.coinfotech.com>
	 <1112895580.10366.71.camel@lade.trondhjem.org>
Reply-To: vasiliy@lohankin.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJeTv-0001SQ-HQ
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 14:24:07 -0700
Received: from mail.mailsvc.com ([63.247.192.101] helo=mailsvc.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJeTt-0002DG-2E
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 14:24:07 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1112895580.10366.71.camel@lade.trondhjem.org>
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


Thank you very much. I will read on!

On Thu, 2005-04-07 at 13:39 -0400, Trond Myklebust wrote:
> to den 07.04.2005 Klokka 11:14 (-0600) skreiv Vasiliy Boulytchev:
> > 	A new task has come up, and we are looking back at NFS, since samba
> > really does not allow us to have proper user arrangements.  I really am
> > afraid of having stale mounts again.  Is this a common newbie problem,
> > or is this the nature of NFS?  When either of the nodes becomes
> > unstable, has to reboot, (or a failover occurs), does this mean the
> > other node will have a stale mount point and will need a reboot?
> 
> A server reboot should not require a client reboot, given a properly
> configured system, however you do need to understand some of the
> limitations of the NFS model.
> 
> NFS relies heavily on the use of "filehandles" in order to ensure that
> we can retain posix behaviour in cases where a rename() of the file or
> some element of the path occurs on the server.
> In order to have the required properties, filehandles tend to have to
> encode information such as device id (known as the "fsid" in NFS-lingo)
> and file inode number. If one or more of those changes, then an ESTALE
> is likely to occur.
> 
> One common cause of ESTALE on reboot is that the device id changes after
> reboot (fibre channel being a notable culprit). In order to fix the
> problem of the filehandles going stale, the Linux kernel server has an
> export option "fsid" which allows you to fix the device id to some
> arbitrary value. (See the "exports" manpage for more info)
> 
> The other common problem is that the filesystem may not support any
> equivalent of the inode number in permanent storage (MS filesystems tend
> to have a problem here). We currently have no good solution for that
> problem on Linux (partly because the NFSv2/v3 protocols did not really
> allow for it at all). We are certainly planning on hardening the client,
> and allowing for some recovery, but the whole problem can be avoided, by
> choosing a filesystem with good NFS support (ext2/ext3, XFS, reiserfs3
> are among the list of good choices). The NFS FAQ has a more complete
> section on this issue.
> 
> Cheers,
>   Trond
-- 

-------------
Vasiliy Boulytchev
Colorado Information Technologies Inc.
http://www.coinfotech.com



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
