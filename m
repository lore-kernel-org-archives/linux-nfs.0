From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS oops on 2.6.14.2
Date: Tue, 29 Nov 2005 16:26:37 -0500
Message-ID: <1133299597.17363.2.camel@lade.trondhjem.org>
References: <20051129200013.GB6326@tau.solarneutrino.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EhD04-0002Na-Lm
	for nfs@lists.sourceforge.net; Tue, 29 Nov 2005 13:26:56 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EhD01-0002RG-7Q
	for nfs@lists.sourceforge.net; Tue, 29 Nov 2005 13:26:56 -0800
To: Ryan Richter <ryan@tau.solarneutrino.net>
In-Reply-To: <20051129200013.GB6326@tau.solarneutrino.net>
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

On Tue, 2005-11-29 at 15:00 -0500, Ryan Richter wrote:
> I got an oops on two NFS clients after upgrading to 2.6.14.2.
> 
> Here's one:
> 
> Unable to handle kernel NULL pointer dereference at 0000000000000018 RIP:
> <ffffffff801dbd9e>{nlmclnt_mark_reclaim+62}
> PGD 7bdd4067 PUD 7bdd5067 PMD 0
> Oops: 0000 [1]
> CPU 0
> Modules linked in:
> Pid: 1317, comm: lockd Not tainted 2.6.14.2 #2
> RIP: 0010:[<ffffffff801dbd9e>] <ffffffff801dbd9e>{nlmclnt_mark_reclaim+62}
> RSP: 0018:ffff81007dfade70  EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffff81007ad80b00 RCX: ffff81007e22d858
> RDX: ffff81007e22d8f0 RSI: ffff81007e22d8e8 RDI: ffff81007ad80b00
> RBP: ffff81007ec18800 R08: 00000000fffffffa R09: 0000000000000001
> R10: 00000000ffffffff R11: 0000000000000000 R12: 0000000000000000
> R13: 0000000000000000 R14: ffffffff803ec420 R15: ffff81007df61014
> FS:  00002aaaab00c4a0(0000) GS:ffffffff804b6800(0000) knlGS:00000000555e68a0
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000018 CR3: 000000007c8fc000 CR4: 00000000000006e0
> Process lockd (pid: 1317, threadinfo ffff81007dfac000, task ffff81007eea61c0)
> Stack: ffffffff801dbe6b ffff81007ad80b00 ffffffff801e3d8c 3256cc84d4030002
>        0000000000000000 ffff81007df4ec68 ffff81007df4ec00 ffffffff803ed4a0
>        ffff81007df4eca0 ffff81007df4ec68
> Call Trace:<ffffffff801dbe6b>{nlmclnt_recovery+139} <ffffffff801e3d8c>{nlm4svc_proc_sm_notify+188}
>        <ffffffff8034c5a4>{svc_process+884} <ffffffff8012ab40>{default_wake_function+0}
>        <ffffffff801dde00>{lockd+352} <ffffffff801ddca0>{lockd+0}
>        <ffffffff8010e352>{child_rip+8} <ffffffff801ddca0>{lockd+0}
>        <ffffffff801ddca0>{lockd+0} <ffffffff8010e34a>{child_rip+0}
> 
> 
> Code: 48 39 78 18 75 1c 8b 86 8c 00 00 00 a8 01 74 12 83 c8 02 89
> RIP <ffffffff801dbd9e>{nlmclnt_mark_reclaim+62} RSP <ffff81007dfade70>
> CR2: 0000000000000018
>  <4>do_vfs_lock: VFS is out of sync with lock manager!
> do_vfs_lock: VFS is out of sync with lock manager!
> 
> 
> And another (different machine, but essentially identical to the one that
> produced the previous):
> 
> Unable to handle kernel NULL pointer dereference at 0000000000000018 RIP:
> <ffffffff801dbd9e>{nlmclnt_mark_reclaim+62}
> PGD 7bdd1067 PUD 7bdd2067 PMD 0
> Oops: 0000 [1]
> CPU 0
> Modules linked in:
> Pid: 1317, comm: lockd Not tainted 2.6.14.2 #2
> RIP: 0010:[<ffffffff801dbd9e>] <ffffffff801dbd9e>{nlmclnt_mark_reclaim+62}
> RSP: 0018:ffff81007dfade70  EFLAGS: 00010246
> RAX: 0000000000000000 RBX: ffff810079254d40 RCX: ffff81007e227858
> RDX: ffff81007e2278f0 RSI: ffff81007e2278e8 RDI: ffff810079254d40
> RBP: ffff81007ec0de00 R08: 00000000fffffffa R09: 0000000000000001
> R10: 00000000ffffffff R11: 0000000000000000 R12: 0000000000000000
> R13: 0000000000000000 R14: ffffffff803ec420 R15: ffff81007df3d014
> FS:  00002aaaab00c4a0(0000) GS:ffffffff804b6800(0000) knlGS:0000000055efbd20
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000018 CR3: 000000007d30f000 CR4: 00000000000006e0
> Process lockd (pid: 1317, threadinfo ffff81007dfac000, task ffff81007eea61c0)
> Stack: ffffffff801dbe6b ffff810079254d40 ffffffff801e3d8c 3256cc84d4030002
>        0000000000000000 ffff81007df39c68 ffff81007df39c00 ffffffff803ed4a0
>        ffff81007df39ca0 ffff81007df39c68
> Call Trace:<ffffffff801dbe6b>{nlmclnt_recovery+139} <ffffffff801e3d8c>{nlm4svc_proc_sm_notify+188}
>        <ffffffff8034c5a4>{svc_process+884} <ffffffff8012ab40>{default_wake_function+0}
>        <ffffffff801dde00>{lockd+352} <ffffffff801ddca0>{lockd+0}
>        <ffffffff8010e352>{child_rip+8} <ffffffff801ddca0>{lockd+0}
>        <ffffffff801ddca0>{lockd+0} <ffffffff8010e34a>{child_rip+0}
> 
> 
> Code: 48 39 78 18 75 1c 8b 86 8c 00 00 00 a8 01 74 12 83 c8 02 89
> RIP <ffffffff801dbd9e>{nlmclnt_mark_reclaim+62} RSP <ffff81007dfade70>
> CR2: 0000000000000018

Both presumably following a server reboot?

Do you have any sure-fire way to reproduce it?

> These machines have an NFS-mounted root, but this is mounted nolock so I'm
> assuming that's unrelated.  The other NFS mounts have options like:
> 
> rw,nosuid,nodev,v3,rsize=8192,wsize=8192,hard,intr,udp,lock
> 
> I've also been seeing lots of the "do_vfs_lock: VFS is out of sync with lock
> manager!", but that has been happening at least since 2.6.13.

That is usually the result of doing kill -9/kill -TERM/kill -INT on a
process that was in the act of grabbing a lock.

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
