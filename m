From: James Pearson <james-p@moving-picture.com>
Subject: Re: inode number mismatch message
Date: Thu, 04 Apr 2002 10:04:40 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CAC1728.F07F4EBD@moving-picture.com>
References: <62D26CC4CB1CD3118EAA00805FBB65FA0B8B900E@perm01.woodside.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16t3As-0004ez-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Apr 2002 01:04:54 -0800
To: "Kent, Ian I." <Ian.Kent@woodside.com.au>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

A previous message from Trond had a workaround:

http://marc.theaimsgroup.com/?l=linux-nfs&m=101316526524213&w=2

I believe this change is in Trond's 2.4.18 patches ...

James Pearson


"Kent, Ian I." wrote:
> 
> I recently got a rash of messages like these in the logs on our Linux
> clients:
> 
> Mar 24 04:02:00 csl024 syslogd 1.4-0: restart.
> Mar 24 04:02:00 csl024 syslogd 1.4-0: restart.
> Mar 24 23:50:13 csl024 kernel: nfs: server perseus is not responding
> Mar 24 23:50:28 csl024 kernel: nfs: server perseus OK
> Mar 24 23:51:43 csl024 kernel: nfs_refresh_inode: inode number mismatch
> Mar 24 23:51:43 csl024 kernel: expected (0x2813c6d/0x4), got
> (0xa000013c6d/0x4)
> Mar 24 23:51:43 csl024 kernel: nfs_refresh_inode: inode number mismatch
> Mar 24 23:51:43 csl024 kernel: expected (0x2813c69/0x4), got
> (0xa000013c69/0x4)
> Mar 24 23:52:58 csl024 kernel: nfs_refresh_inode: inode number mismatch
> Mar 24 23:52:58 csl024 kernel: expected (0x2813c6d/0x4), got
> (0xa000013c6d/0x4)
> Mar 24 23:52:58 csl024 kernel: nfs_refresh_inode: inode number mismatch
> Mar 24 23:52:58 csl024 kernel: expected (0x2813c69/0x4), got
> (0xa000013c69/0x4)
> 
> They appeared after the server (Solaris) to which the Linux (2.4.17 kernel
> with Tronds' patches) was upgraded from 2.6 to 2.8 while there were active
> mounts.
> 
> I know it's a big ask to expect the client to be OK though such an activity,
> but the comment is 'the Solaris clients were OK after the upgrade'.
> 
> I would appreciate an feedback on whether this is something that should
> fixable or not.
> 
> Regards
> Ian Kent
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
