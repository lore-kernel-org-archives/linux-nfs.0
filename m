Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:44791 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761229Ab3JPUSz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 16:18:55 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Fix NULL dereference in recovery path
Date: Wed, 16 Oct 2013 20:18:53 +0000
Message-ID: <1381954731.17178.28.camel@leira.trondhjem.org>
References: <1381188833-3728-1-git-send-email-dros@netapp.com>
In-Reply-To: <1381188833-3728-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-10-07 at 19:33 -0400, Weston Andros Adamson wrote:
+AD4- +AF8-nfs4+AF8-opendata+AF8-reclaim+AF8-to+AF8-nfs4+AF8-state doesn't expect to see a cached
+AD4- open CLAIM+AF8-PREVIOUS, but this can happen. An example is when there are
+AD4- RDWR openers and RDONLY openers on a delegation stateid. The recovery
+AD4- path will first try an open CLAIM+AF8-PREVIOUS for the RDWR openers, this
+AD4- marks the delegation as not needing RECLAIM anymore, so the open
+AD4- CLAIM+AF8-PREVIOUS for the RDONLY openers will not actually send an rpc.
+AD4- 
+AD4- The NULL dereference is due to +AF8-nfs4+AF8-opendata+AF8-reclaim+AF8-to+AF8-nfs4+AF8-state
+AD4- returning PTR+AF8-ERR(rpc+AF8-status) when +ACE-rpc+AF8-done. When the open is
+AD4- cached, rpc+AF8-done +AD0APQ- 0 and rpc+AF8-status +AD0APQ- 0, thus
+AD4- +AF8-nfs4+AF8-opendata+AF8-reclaim+AF8-to+AF8-nfs4+AF8-state returns NULL - this is unexpected
+AD4- by callers of nfs4+AF8-opendata+AF8-to+AF8-nfs4+AF8-state().
+AD4- 
+AD4- This can be reproduced easily by opening the same file two times on an
+AD4- NFSv4.0 mount with delegations enabled, once as RDONLY and once as RDWR then
+AD4- sleeping for a long time.  While the files are held open, kick off state
+AD4- recovery and this NULL dereference will be hit every time.
+AD4- 
+AD4- An example OOPS:
+AD4- 
+AD4- +AFs-   65.003602+AF0- BUG: unable to handle kernel NULL pointer dereference at 00000000
+AD4- 00000030
+AD4- +AFs-   65.005312+AF0- IP: +AFsAPA-ffffffffa037d6ee+AD4AXQ- +AF8AXw-nfs4+AF8-close+-0x1e/0x160 +AFs-nfsv4+AF0-
+AD4- +AFs-   65.006820+AF0- PGD 7b0ea067 PUD 791ff067 PMD 0
+AD4- +AFs-   65.008075+AF0- Oops: 0000 +AFsAIw-1+AF0- SMP
+AD4- +AFs-   65.008802+AF0- Modules linked in: rpcsec+AF8-gss+AF8-krb5 nfsv4 dns+AF8-resolver nfs fscache
+AD4-  snd+AF8-ens1371 gameport nfsd snd+AF8-rawmidi snd+AF8-ac97+AF8-codec ac97+AF8-bus btusb snd+AF8-seq snd
+AD4- +AF8-seq+AF8-device snd+AF8-pcm ppdev bluetooth auth+AF8-rpcgss coretemp snd+AF8-page+AF8-alloc crc32+AF8-pc
+AD4- lmul crc32c+AF8-intel ghash+AF8-clmulni+AF8-intel microcode rfkill nfs+AF8-acl vmw+AF8-balloon serio
+AD4- +AF8-raw snd+AF8-timer lockd parport+AF8-pc e1000 snd soundcore parport i2c+AF8-piix4 shpchp vmw
+AD4- +AF8-vmci sunrpc ata+AF8-generic mperf pata+AF8-acpi mptspi vmwgfx ttm scsi+AF8-transport+AF8-spi dr
+AD4- m mptscsih mptbase i2c+AF8-core
+AD4- +AFs-   65.018684+AF0- CPU: 0 PID: 473 Comm: 192.168.10.85-m Not tainted 3.11.2-201.fc19
+AD4- .x86+AF8-64 +ACM-1
+AD4- +AFs-   65.020113+AF0- Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop
+AD4-  Reference Platform, BIOS 6.00 07/31/2013
+AD4- +AFs-   65.022012+AF0- task: ffff88003707e320 ti: ffff88007b906000 task.ti: ffff88007b906000
+AD4- +AFs-   65.023414+AF0- RIP: 0010:+AFsAPA-ffffffffa037d6ee+AD4AXQ-  +AFsAPA-ffffffffa037d6ee+AD4AXQ- +AF8AXw-nfs4+AF8-close+-0x1e/0x160 +AFs-nfsv4+AF0-
+AD4- +AFs-   65.025079+AF0- RSP: 0018:ffff88007b907d10  EFLAGS: 00010246
+AD4- +AFs-   65.026042+AF0- RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
+AD4- +AFs-   65.027321+AF0- RDX: 0000000000000050 RSI: 0000000000000001 RDI: 0000000000000000
+AD4- +AFs-   65.028691+AF0- RBP: ffff88007b907d38 R08: 0000000000016f60 R09: 0000000000000000
+AD4- +AFs-   65.029990+AF0- R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000001
+AD4- +AFs-   65.031295+AF0- R13: 0000000000000050 R14: 0000000000000000 R15: 0000000000000001
+AD4- +AFs-   65.032527+AF0- FS:  0000000000000000(0000) GS:ffff88007f600000(0000) knlGS:0000000000000000
+AD4- +AFs-   65.033981+AF0- CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
+AD4- +AFs-   65.035177+AF0- CR2: 0000000000000030 CR3: 000000007b27f000 CR4: 00000000000407f0
+AD4- +AFs-   65.036568+AF0- Stack:
+AD4- +AFs-   65.037011+AF0-  0000000000000000 0000000000000001 ffff88007b907d90 ffff88007a880220
+AD4- +AFs-   65.038472+AF0-  ffff88007b768de8 ffff88007b907d48 ffffffffa037e4a5 ffff88007b907d80
+AD4- +AFs-   65.039935+AF0-  ffffffffa036a6c8 ffff880037020e40 ffff88007a880000 ffff880037020e40
+AD4- +AFs-   65.041468+AF0- Call Trace:
+AD4- +AFs-   65.042050+AF0-  +AFsAPA-ffffffffa037e4a5+AD4AXQ- nfs4+AF8-close+AF8-state+-0x15/0x20 +AFs-nfsv4+AF0-
+AD4- +AFs-   65.043209+AF0-  +AFsAPA-ffffffffa036a6c8+AD4AXQ- nfs4+AF8-open+AF8-recover+AF8-helper+-0x148/0x1f0 +AFs-nfsv4+AF0-
+AD4- +AFs-   65.044529+AF0-  +AFsAPA-ffffffffa036a886+AD4AXQ- nfs4+AF8-open+AF8-recover+-0x116/0x150 +AFs-nfsv4+AF0-
+AD4- +AFs-   65.045730+AF0-  +AFsAPA-ffffffffa036d98d+AD4AXQ- nfs4+AF8-open+AF8-reclaim+-0xad/0x150 +AFs-nfsv4+AF0-
+AD4- +AFs-   65.046905+AF0-  +AFsAPA-ffffffffa037d979+AD4AXQ- nfs4+AF8-do+AF8-reclaim+-0x149/0x5f0 +AFs-nfsv4+AF0-
+AD4- +AFs-   65.048071+AF0-  +AFsAPA-ffffffffa037e1dc+AD4AXQ- nfs4+AF8-run+AF8-state+AF8-manager+-0x3bc/0x670 +AFs-nfsv4+AF0-
+AD4- +AFs-   65.049436+AF0-  +AFsAPA-ffffffffa037de20+AD4AXQ- ? nfs4+AF8-do+AF8-reclaim+-0x5f0/0x5f0 +AFs-nfsv4+AF0-
+AD4- +AFs-   65.050686+AF0-  +AFsAPA-ffffffffa037de20+AD4AXQ- ? nfs4+AF8-do+AF8-reclaim+-0x5f0/0x5f0 +AFs-nfsv4+AF0-
+AD4- +AFs-   65.051943+AF0-  +AFsAPA-ffffffff81088640+AD4AXQ- kthread+-0xc0/0xd0
+AD4- +AFs-   65.052831+AF0-  +AFsAPA-ffffffff81088580+AD4AXQ- ? insert+AF8-kthread+AF8-work+-0x40/0x40
+AD4- +AFs-   65.054697+AF0-  +AFsAPA-ffffffff8165686c+AD4AXQ- ret+AF8-from+AF8-fork+-0x7c/0xb0
+AD4- +AFs-   65.056396+AF0-  +AFsAPA-ffffffff81088580+AD4AXQ- ? insert+AF8-kthread+AF8-work+-0x40/0x40
+AD4- +AFs-   65.058208+AF0- Code: 5c 41 5d 5d c3 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55 48 89 e5 41 57 41 89 f7 41 56 41 89 ce 41 55 41 89 d5 41 54 53 48 89 fb +ADw-4c+AD4- 8b 67 30 f0 41 ff 44 24 44 49 8d 7c 24 40 e8 0e 0a 2d e1 44
+AD4- +AFs-   65.065225+AF0- RIP  +AFsAPA-ffffffffa037d6ee+AD4AXQ- +AF8AXw-nfs4+AF8-close+-0x1e/0x160 +AFs-nfsv4+AF0-
+AD4- +AFs-   65.067175+AF0-  RSP +ADw-ffff88007b907d10+AD4-
+AD4- +AFs-   65.068570+AF0- CR2: 0000000000000030
+AD4- +AFs-   65.070098+AF0- ---+AFs- end trace 0d1fe4f5c7dd6f8b +AF0----
+AD4- 
+AD4- Signed-off-by: Weston Andros Adamson +ADw-dros+AEA-netapp.com+AD4-
+AD4- ---
+AD4-  fs/nfs/nfs4proc.c +AHw- 25 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+------
+AD4-  1 file changed, 20 insertions(+-), 5 deletions(-)
+AD4- 
+AD4- diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
+AD4- index d2b4845..58658db 100644
+AD4- --- a/fs/nfs/nfs4proc.c
+AD4- +-+-+- b/fs/nfs/nfs4proc.c
+AD4- +AEAAQA- -1316,16 +-1316,27 +AEAAQA- +AF8-nfs4+AF8-opendata+AF8-reclaim+AF8-to+AF8-nfs4+AF8-state(struct nfs4+AF8-opendata +ACo-data)
+AD4-  	struct inode +ACo-inode +AD0- data-+AD4-state-+AD4-inode+ADs-
+AD4-  	struct nfs4+AF8-state +ACo-state +AD0- data-+AD4-state+ADs-
+AD4-  	int ret+ADs-
+AD4- +-	bool cached+AF8-open +AD0- false+ADs-
+AD4-  
+AD4-  	if (+ACE-data-+AD4-rpc+AF8-done) +AHs-
+AD4- -		ret +AD0- data-+AD4-rpc+AF8-status+ADs-
+AD4- -		goto err+ADs-
+AD4- +-		if (data-+AD4-rpc+AF8-status) +AHs-
+AD4- +-			ret +AD0- data-+AD4-rpc+AF8-status+ADs-
+AD4- +-			goto err+ADs-
+AD4- +-		+AH0- else
+AD4- +-			/+ACo-
+AD4- +-			 +ACo- This is a cached open from an earlier operation
+AD4- +-			 +ACo- of the current state recovery event so there is
+AD4- +-			 +ACo- no need to update or check anything, just lookup
+AD4- +-			 +ACo- the open state.
+AD4- +-			 +ACo-/
+AD4- +-			cached+AF8-open +AD0- true+ADs-
+AD4-  	+AH0-
+AD4-  
+AD4-  	ret +AD0- -ESTALE+ADs-
+AD4- -	if (+ACE-(data-+AD4-f+AF8-attr.valid +ACY- NFS+AF8-ATTR+AF8-FATTR+AF8-TYPE) +AHwAfA-
+AD4- -	    +ACE-(data-+AD4-f+AF8-attr.valid +ACY- NFS+AF8-ATTR+AF8-FATTR+AF8-FILEID) +AHwAfA-
+AD4- -	    +ACE-(data-+AD4-f+AF8-attr.valid +ACY- NFS+AF8-ATTR+AF8-FATTR+AF8-CHANGE))
+AD4- +-	if (+ACE-cached+AF8-open +ACYAJg-
+AD4- +-	    (+ACE-(data-+AD4-f+AF8-attr.valid +ACY- NFS+AF8-ATTR+AF8-FATTR+AF8-TYPE) +AHwAfA-
+AD4- +-	     +ACE-(data-+AD4-f+AF8-attr.valid +ACY- NFS+AF8-ATTR+AF8-FATTR+AF8-FILEID) +AHwAfA-
+AD4- +-	     +ACE-(data-+AD4-f+AF8-attr.valid +ACY- NFS+AF8-ATTR+AF8-FATTR+AF8-CHANGE)))
+AD4-  		goto err+ADs-
+AD4-  
+AD4-  	ret +AD0- -ENOMEM+ADs-
+AD4- +AEAAQA- -1333,6 +-1344,9 +AEAAQA- +AF8-nfs4+AF8-opendata+AF8-reclaim+AF8-to+AF8-nfs4+AF8-state(struct nfs4+AF8-opendata +ACo-data)
+AD4-  	if (state +AD0APQ- NULL)
+AD4-  		goto err+ADs-
+AD4-  
+AD4- +-	if (cached+AF8-open)
+AD4- +-		goto out+ADs-
+AD4- +-
+AD4-  	ret +AD0- nfs+AF8-refresh+AF8-inode(inode, +ACY-data-+AD4-f+AF8-attr)+ADs-
+AD4-  	if (ret)
+AD4-  		goto err+ADs-
+AD4- +AEAAQA- -1344,6 +-1358,7 +AEAAQA- +AF8-nfs4+AF8-opendata+AF8-reclaim+AF8-to+AF8-nfs4+AF8-state(struct nfs4+AF8-opendata +ACo-data)
+AD4-  	update+AF8-open+AF8-stateid(state, +ACY-data-+AD4-o+AF8-res.stateid, NULL,
+AD4-  			    data-+AD4-o+AF8-arg.fmode)+ADs-
+AD4-  
+AD4- +-out:
+AD4-  	return state+ADs-
+AD4-  err:
+AD4-  	return ERR+AF8-PTR(ret)+ADs-

OK. Looking at what +AF8-nfs4+AF8-opendata+AF8-reclaim+AF8-to+AF8-nfs4+AF8-state is supposed to
do, there appear to be several more problems.

     1. Why are we calling nfs4+AF8-get+AF8-open+AF8-state? We already have a value
        for state, and all we want to do is to update it (and bump the
        reference counter).
     2. Why do we care about whether or not the GETATTR succeeded? We
        just did an open by filehandle.
     3. Don't we have a state reference leak when nfs+AF8-refresh+AF8-inode
        fails?


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
