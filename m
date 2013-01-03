Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:57328 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753544Ab3ACUr7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2013 15:47:59 -0500
Received: from vmwexceht03-prd.hq.netapp.com (exchsmtp.hq.netapp.com [10.106.76.241])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id r03Klwvd002670
	for <linux-nfs@vger.kernel.org>; Thu, 3 Jan 2013 12:47:58 -0800 (PST)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Fix access to suid/sgid executables
Date: Thu, 3 Jan 2013 20:47:57 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91198820D@SACEXCMBX04-PRD.hq.netapp.com>
References: <1357245193-10375-1-git-send-email-dros@netapp.com>
In-Reply-To: <1357245193-10375-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-01-03 at 15:33 -0500, Weston Andros Adamson wrote:
+AD4- nfs+AF8-open+AF8-permission+AF8-mask() shouldn't check MAY+AF8-READ for suid/sgid files that
+AD4- are opened with +AF8AXw-FMODE+AF8-EXEC.
+AD4- 
+AD4- Also fix NFSv4 access-in-open path in a similar way -- openflags must be
+AD4- used because fmode will not always have FMODE+AF8-EXEC set.
+AD4- 
+AD4- Signed-off-by: Weston Andros Adamson +ADw-dros+AEA-netapp.com+AD4-
+AD4- ---
+AD4- 
+AD4- This patch fixes https://bugzilla.kernel.org/show+AF8-bug.cgi?id+AD0-49101
+AD4- 
+AD4- The fix is not as obvious or clean as I'd like, so here is a little background:
+AD4- 
+AD4- Not checking MAY+AF8-READ when a S+AF8-ISUID or S+AF8-ISGID file has MAY+AF8-EXEC causes
+AD4- suid/sgid executables to behave the same as on a local FS.
+AD4- 
+AD4- The second part is fixing open-in-access for NFSv4 - we want to do the same
+AD4- thing as in nfs+AF8-open+AF8-permission+AF8-mask, but oddly enough fmode doesn't always
+AD4- indicate that the file is being opened for execution.  Instead we have to
+AD4- use the openflags for this.
+AD4- 
+AD4- Adding some debug prints show that the first exec of a suid/sgid
+AD4- file will open with fmode containing FMODE+AF8-EXEC and FMODE+AF8-READ, but subsequent
+AD4- execs will open with fmode containing FMODE+AF8-READ, but not FMODE+AF8-EXEC.
+AD4- openflags always has +AF8AXw-FMODE+AF8-EXEC set in these examples.
+AD4- 
+AD4- The first exec has these values in nfs4+AF8-opendata+AF8-access():
+AD4- 
+AD4- fmode +AD0- 0x21: contains read exec
+AD4- openflags +AD0- 0x8020: contains exec
+AD4- 
+AD4- The second (and subsequent) execs have these values in nfs4+AF8-opendata+AF8-access():
+AD4- 
+AD4- fmode +AD0- 0x1: contains read
+AD4- openflags +AD0- 0x8020: contains exec
+AD4- 
+AD4-  -dros
+AD4- 
+AD4-  fs/nfs/dir.c      +AHw-   12 +-+-+-+-+-+-+-+-+----
+AD4-  fs/nfs/nfs4proc.c +AHw-   13 +-+-+-+-+-+-+-+-+-+-+---
+AD4-  2 files changed, 20 insertions(+-), 5 deletions(-)
+AD4- 
+AD4- diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
+AD4- index 32e6c53..5141243 100644
+AD4- --- a/fs/nfs/dir.c
+AD4- +-+-+- b/fs/nfs/dir.c
+AD4- +AEAAQA- -2149,7 +-2149,7 +AEAAQA- out:
+AD4-  	return -EACCES+ADs-
+AD4-  +AH0-
+AD4-  
+AD4- -static int nfs+AF8-open+AF8-permission+AF8-mask(int openflags)
+AD4- +-static int nfs+AF8-open+AF8-permission+AF8-mask(struct inode +ACo-inode, int openflags)
+AD4-  +AHs-
+AD4-  	int mask +AD0- 0+ADs-
+AD4-  
+AD4- +AEAAQA- -2157,14 +-2157,20 +AEAAQA- static int nfs+AF8-open+AF8-permission+AF8-mask(int openflags)
+AD4-  		mask +AHwAPQ- MAY+AF8-READ+ADs-
+AD4-  	if ((openflags +ACY- O+AF8-ACCMODE) +ACEAPQ- O+AF8-RDONLY)
+AD4-  		mask +AHwAPQ- MAY+AF8-WRITE+ADs-
+AD4- -	if (openflags +ACY- +AF8AXw-FMODE+AF8-EXEC)
+AD4- +-	if (openflags +ACY- +AF8AXw-FMODE+AF8-EXEC) +AHs-
+AD4-  		mask +AHwAPQ- MAY+AF8-EXEC+ADs-
+AD4- +-		/+ACo- don't check MAY+AF8-READ for exec of suid/sgid +ACo-/
+AD4- +-		if (inode-+AD4-i+AF8-mode +ACY- (S+AF8-ISUID +AHw- S+AF8-ISGID))
+AD4- +-			mask +ACYAPQ- +AH4-MAY+AF8-READ+ADs-

Wait, this can't be right. Why does the presence of a suid/sgid flag
make a difference here? Either way, if +AF8AXw-FMODE+AF8-EXEC access is requested,
then we should only need MAY+AF8-EXEC rights.

+AD4- +-	+AH0-
+AD4- +-
+AD4-  	return mask+ADs-
+AD4-  +AH0-
+AD4-  
+AD4-  int nfs+AF8-may+AF8-open(struct inode +ACo-inode, struct rpc+AF8-cred +ACo-cred, int openflags)
+AD4-  +AHs-
+AD4- -	return nfs+AF8-do+AF8-access(inode, cred, nfs+AF8-open+AF8-permission+AF8-mask(openflags))+ADs-
+AD4- +-	return nfs+AF8-do+AF8-access(inode, cred,
+AD4- +-		nfs+AF8-open+AF8-permission+AF8-mask(inode, openflags))+ADs-
+AD4-  +AH0-
+AD4-  EXPORT+AF8-SYMBOL+AF8-GPL(nfs+AF8-may+AF8-open)+ADs-
+AD4-  
+AD4- diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
+AD4- index 5d864fb..23cf1a8 100644
+AD4- --- a/fs/nfs/nfs4proc.c
+AD4- +-+-+- b/fs/nfs/nfs4proc.c
+AD4- +AEAAQA- -1626,7 +-1626,8 +AEAAQA- static int +AF8-nfs4+AF8-recover+AF8-proc+AF8-open(struct nfs4+AF8-opendata +ACo-data)
+AD4-  
+AD4-  static int nfs4+AF8-opendata+AF8-access(struct rpc+AF8-cred +ACo-cred,
+AD4-  				struct nfs4+AF8-opendata +ACo-opendata,
+AD4- -				struct nfs4+AF8-state +ACo-state, fmode+AF8-t fmode)
+AD4- +-				struct nfs4+AF8-state +ACo-state, fmode+AF8-t fmode,
+AD4- +-				int openflags)
+AD4-  +AHs-
+AD4-  	struct nfs+AF8-access+AF8-entry cache+ADs-
+AD4-  	u32 mask+ADs-
+AD4- +AEAAQA- -1644,6 +-1645,14 +AEAAQA- static int nfs4+AF8-opendata+AF8-access(struct rpc+AF8-cred +ACo-cred,
+AD4-  	if (fmode +ACY- FMODE+AF8-EXEC)
+AD4-  		mask +AHwAPQ- MAY+AF8-EXEC+ADs-
+AD4-  
+AD4- +-	/+ACo- use openflags to check for exec of suid/sgid, because fmode won't
+AD4- +-	 +ACo- always have FMODE+AF8-EXEC set by VFS.
+AD4- +-	 +ACo- Also, don't check MAY+AF8-READ on a suid/sgid file being executed +ACo-/
+AD4- +-	if ((openflags +ACY- +AF8AXw-FMODE+AF8-EXEC) +ACYAJg-
+AD4- +-	    (state-+AD4-inode-+AD4-i+AF8-mode +ACY- (S+AF8-ISUID +AHw- S+AF8-ISGID))) +AHs-
+AD4- +-		mask +AD0- MAY+AF8-EXEC+ADs-
+AD4- +-	+AH0-

Ditto...

+AD4- +-
+AD4-  	cache.cred +AD0- cred+ADs-
+AD4-  	cache.jiffies +AD0- jiffies+ADs-
+AD4-  	nfs+AF8-access+AF8-set+AF8-mask(+ACY-cache, opendata-+AD4-o+AF8-res.access+AF8-result)+ADs-
+AD4- +AEAAQA- -1896,7 +-1905,7 +AEAAQA- static int +AF8-nfs4+AF8-do+AF8-open(struct inode +ACo-dir,
+AD4-  	if (server-+AD4-caps +ACY- NFS+AF8-CAP+AF8-POSIX+AF8-LOCK)
+AD4-  		set+AF8-bit(NFS+AF8-STATE+AF8-POSIX+AF8-LOCKS, +ACY-state-+AD4-flags)+ADs-
+AD4-  
+AD4- -	status +AD0- nfs4+AF8-opendata+AF8-access(cred, opendata, state, fmode)+ADs-
+AD4- +-	status +AD0- nfs4+AF8-opendata+AF8-access(cred, opendata, state, fmode, flags)+ADs-
+AD4-  	if (status +ACEAPQ- 0)
+AD4-  		goto err+AF8-opendata+AF8-put+ADs-
+AD4-  

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
