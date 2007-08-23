From: Zoot <z00t@gmx.net>
Subject: Re: umount fails with device busy
Date: Thu, 23 Aug 2007 22:39:11 +0200
Message-ID: <20070823203911.GD4692@localhost>
References: <20070823184544.237460@gmx.net> <46CDE805.4090909@oracle.com>
	<46CDEE3A.3040809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOJSc-0003jG-RB
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 13:39:22 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1IOJSe-0000rs-Hb
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 13:39:27 -0700
In-Reply-To: <46CDEE3A.3040809@redhat.com>
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

On Thu, Aug 23, 2007 at 04:29:46PM -0400, Peter Staubach wrote:
> Chuck Lever wrote:
> >z00t@gmx.net wrote:
> >>Hi guys,
> >>
> >>I get the device busy error when I try to umount an NFS file system 
> >>although there is no process with an open file on it (at least fuser 
> >>-m /mnt/point and lsof +f -- /mnt/point don't find anything).
> >>
> >>To be more precise this only happens, when I run the umount right 
> >>after stopping an application which has its executables and work 
> >>directory on this file system. Running umount again some seconds 
> >>later works fine.
> >>I do not have any submounts under this mount point. There are no 
> >>packet transmit or receive errors nor any NFS/RPC errors only a very 
> >>small number of RPC retransmitts. So it seems that I have a stable 
> >>environment. Client and server is SLES9 with 2.6.5-7.202.7-smp/X86_64.
> >>I enabled NFS debug output and the only noticeable thing is, that 
> >>some NFS operations are still ongoing after the application processes 
> >>have already terminated:
> >>
> >>  Aug 23 08:25:23 marvin kernel: NFS reply getattr
> >>  Aug 23 08:25:23 marvin kernel: NFS: nfs_update_inode(0:12/149296 
> >>ct=1 info=0x6)
> >>  Aug 23 08:25:23 marvin kernel: NFS: (0:12/149296) revalidation 
> >>complete
> >>  Aug 23 08:25:23 marvin kernel: nfs: flush(0:12/149296)
> >>  Aug 23 08:25:23 marvin kernel: NFS: dentry_delete(bin/stop, 0)
> >>  Aug 23 08:25:23 marvin kernel: NFS: revalidating (0:12/2)
> >>  Aug 23 08:25:23 marvin kernel: NFS call  getattr
> >>  Aug 23 08:25:23 marvin kernel: NFS reply getattr
> >>  Aug 23 08:25:23 marvin kernel: NFS: nfs_update_inode(0:12/2 ct=1 
> >>info=0x6)
> >>  Aug 23 08:25:23 marvin kernel: NFS: (0:12/2) revalidation complete
> >>  Aug 23 08:25:25 marvin kernel: NFS call  fsstat
> >>  Aug 23 08:25:25 marvin kernel: NFS reply statfs: 0
> >>  Aug 23 08:25:35 marvin kernel: NFS call  fsstat
> >>  Aug 23 08:25:35 marvin kernel: NFS reply statfs: 0
> >>  Aug 23 08:25:38 marvin kernel: NFS: 6368 initiated commit call
> >>  Aug 23 08:25:38 marvin kernel: NFS: 6369 initiated commit call
> >>  Aug 23 08:25:38 marvin kernel: NFS: 6370 initiated commit call
> >>  Aug 23 08:25:38 marvin kernel: NFS: 6371 initiated commit call
> >>  Aug 23 08:25:38 marvin kernel: NFS: 6368 nfs_commit_done (status 0)
> >>  Aug 23 08:25:38 marvin kernel: NFS: commit (0:12/121805 3207@0)NFS: 
> >>dentry_delete(log/mux_marvin.trc, 0)
> >>  Aug 23 08:25:38 marvin kernel:  OK
> >>  Aug 23 08:25:38 marvin kernel: NFS: 6369 nfs_commit_done (status 0)
> >>  Aug 23 08:25:38 marvin kernel: NFS: commit (0:12/149304 2238@0)NFS: 
> >>dentry_delete(log/pw_marvin_1.trc, 0)
> >>  Aug 23 08:25:38 marvin kernel:  OK
> >>  Aug 23 08:25:38 marvin kernel: NFS: 6370 nfs_commit_done (status 0)
> >>  Aug 23 08:25:38 marvin kernel: NFS: commit (0:12/149297 2238@0)NFS: 
> >>dentry_delete(log/pw_marvin_0.trc, 0)
> >>  Aug 23 08:25:38 marvin kernel:  OK
> >>  Aug 23 08:25:38 marvin kernel: NFS: 6371 nfs_commit_done (status 0)
> >>  Aug 23 08:25:38 marvin kernel: NFS: commit (0:12/149295 965@0)NFS: 
> >>dentry_delete(net.trc, 0)
> >>  Aug 23 08:25:38 marvin kernel:  OK
> >>  Aug 23 08:25:45 marvin kernel: NFS call  fsstat
> >>  Aug 23 08:25:45 marvin kernel: NFS reply statfs: 0
> >>  Aug 23 08:25:55 marvin kernel: NFS call  fsstat
> >>
> >>When I run umount during these ops I get an device busy. Any help 
> >>would be very appreciated!
> >
> >This is normal and expected behavior.  One problem may be that your 
> >server is slow, and thus there are RPCs left outstanding for a bit on 
> >your client after your application exits.  The COMMIT calls from that 
> >trace suggest that there is dirty data the client is writing back to 
> >the server. 
> 
> It seems to me that this should not be the expected behavior unless
> the file system is mounted "nocto".  Is it?
> 
>    Thanx...
> 
>       ps
No, mount options are: nfsvers=3,soft,tcp,rsize=32768,wsize=32768

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
