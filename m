From: kenneth johansson <ken@kenjo.org>
Subject: lockd not responding
Date: Wed, 12 Sep 2007 07:26:02 +0000 (UTC)
Message-ID: <fc84aa$o11$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVMcM-0001MD-7c
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 00:26:34 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IVMcQ-0000rL-Dd
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 00:26:39 -0700
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1IVMc1-0001xx-Vm
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:26:13 +0200
Received: from 1-1-4-20a.ras.sth.bostream.se ([82.182.72.90])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:26:13 +0200
Received: from ken by 1-1-4-20a.ras.sth.bostream.se with local (Gmexim 0.1
	(Debian)) id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:26:13 +0200
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

Got a warning from the lock validating check again and
later a unresponsive lockd with a backtrace this time
actually at the same place the lock warning was on.

[68078.860233]  =======================
[68078.860276] lockd         D E4433CD0  5432  2445      2 (L-TLB)
[68078.860419]        e4433cf0 00000046 e4433df4 e4433cd0 c0335db3 00000000 3b9ab342 8c0cfa96 
[68078.860701]        00002591 8c0cfa96 00002591 0000e375 00000073 ecdb0ba0 0000576f 00000000 
[68078.861019]        00000002 c051fc58 e31fea04 00000246 ecdb0a90 e4433d2c c03b7030 00000000 
[68078.861337] Call Trace:
[68078.861414]  [<c03b7030>] __mutex_lock_slowpath+0xa0/0x290
[68078.861490]  [<c03b723c>] mutex_lock+0x1c/0x20
[68078.861565]  [<c02411c9>] nlmsvc_traverse_blocks+0x29/0xa0
[68078.861647]  [<c02425fe>] nlm_traverse_files+0x6e/0x210
[68078.861723]  [<c024282b>] nlmsvc_mark_resources+0x1b/0x30
[68078.861799]  [<c023f02e>] nlm_gc_hosts+0x4e/0x1e0
[68078.861874]  [<c023f576>] nlm_lookup_host+0x46/0x310
[68078.861950]  [<c023f874>] nlmsvc_lookup_host+0x34/0x40
[68078.862026]  [<c02414b5>] nlmsvc_lock+0x125/0x360
[68078.862100]  [<c024562c>] nlm4svc_proc_lock+0x7c/0x110
[68078.862178]  [<c03a4740>] svc_process+0x680/0x730
[68078.862257]  [<c0240166>] lockd+0x106/0x240
[68078.862331]  [<c0104b43>] kernel_thread_helper+0x7/0x14
[68078.862407]  =======================

[21409.476505] =======================================================
[21409.476599] [ INFO: possible circular locking dependency detected ]
[21409.476646] 2.6.22.3 #7
[21409.476688] -------------------------------------------------------
[21409.476735] lockd/2445 is trying to acquire lock:
[21409.476781]  (&file->f_mutex){--..}, at: [<c03b723c>] mutex_lock+0x1c/0x20
[21409.476951] 
[21409.476952] but task is already holding lock:
[21409.477034]  (nlm_host_mutex){--..}, at: [<c03b723c>] mutex_lock+0x1c/0x20
[21409.477198] 
[21409.477199] which lock already depends on the new lock.
[21409.477201] 
[21409.477321] 
[21409.477322] the existing dependency chain (in reverse order) is:
[21409.477405] 
[21409.477406] -> #1 (nlm_host_mutex){--..}:
[21409.477574]        [<c0135d4d>] __lock_acquire+0xdad/0xf60
[21409.477853]        [<c0135f55>] lock_acquire+0x55/0x70
[21409.478128]        [<c03b6ff9>] __mutex_lock_slowpath+0x69/0x290
[21409.478405]        [<c03b723c>] mutex_lock+0x1c/0x20
[21409.478680]        [<c023f561>] nlm_lookup_host+0x31/0x310
[21409.478961]        [<c023f874>] nlmsvc_lookup_host+0x34/0x40
[21409.479238]        [<c02414b5>] nlmsvc_lock+0x125/0x360
[21409.479513]        [<c024562c>] nlm4svc_proc_lock+0x7c/0x110
[21409.479792]        [<c03a4740>] svc_process+0x680/0x730
[21409.480071]        [<c0240166>] lockd+0x106/0x240
[21409.480347]        [<c0104b43>] kernel_thread_helper+0x7/0x14
[21409.480625]        [<ffffffff>] 0xffffffff
[21409.480904] 
[21409.480905] -> #0 (&file->f_mutex){--..}:
[21409.481072]        [<c0135bc7>] __lock_acquire+0xc27/0xf60
[21409.481348]        [<c0135f55>] lock_acquire+0x55/0x70
[21409.481623]        [<c03b6ff9>] __mutex_lock_slowpath+0x69/0x290
[21409.481900]        [<c03b723c>] mutex_lock+0x1c/0x20
[21409.482175]        [<c02411c9>] nlmsvc_traverse_blocks+0x29/0xa0
[21409.482453]        [<c02425fe>] nlm_traverse_files+0x6e/0x210
[21409.482729]        [<c024282b>] nlmsvc_mark_resources+0x1b/0x30
[21409.483005]        [<c023f02e>] nlm_gc_hosts+0x4e/0x1e0
[21409.483281]        [<c023f576>] nlm_lookup_host+0x46/0x310
[21409.483558]        [<c023f874>] nlmsvc_lookup_host+0x34/0x40
[21409.483834]        [<c024506b>] nlm4svc_retrieve_args+0x3b/0xd0
[21409.484111]        [<c0245607>] nlm4svc_proc_lock+0x57/0x110
[21409.484387]        [<c03a4740>] svc_process+0x680/0x730
[21409.484663]        [<c0240166>] lockd+0x106/0x240
[21409.484938]        [<c0104b43>] kernel_thread_helper+0x7/0x14
[21409.485215]        [<ffffffff>] 0xffffffff
[21409.485488] 
[21409.485489] other info that might help us debug this:
[21409.485491] 
[21409.485611] 1 lock held by lockd/2445:
[21409.485654]  #0:  (nlm_host_mutex){--..}, at: [<c03b723c>] mutex_lock+0x1c/0x20
[21409.485855] 
[21409.485856] stack backtrace:
[21409.485937]  [<c0104eca>] show_trace_log_lvl+0x1a/0x30
[21409.486012]  [<c0105a02>] show_trace+0x12/0x20
[21409.486087]  [<c0105a75>] dump_stack+0x15/0x20
[21409.486161]  [<c0133d6c>] print_circular_bug_tail+0x6c/0x80
[21409.486237]  [<c0135bc7>] __lock_acquire+0xc27/0xf60
[21409.486312]  [<c0135f55>] lock_acquire+0x55/0x70
[21409.486386]  [<c03b6ff9>] __mutex_lock_slowpath+0x69/0x290
[21409.486462]  [<c03b723c>] mutex_lock+0x1c/0x20
[21409.487052]  [<c02411c9>] nlmsvc_traverse_blocks+0x29/0xa0
[21409.487129]  [<c02425fe>] nlm_traverse_files+0x6e/0x210
[21409.487204]  [<c024282b>] nlmsvc_mark_resources+0x1b/0x30
[21409.487279]  [<c023f02e>] nlm_gc_hosts+0x4e/0x1e0
[21409.487354]  [<c023f576>] nlm_lookup_host+0x46/0x310
[21409.487430]  [<c023f874>] nlmsvc_lookup_host+0x34/0x40
[21409.487505]  [<c024506b>] nlm4svc_retrieve_args+0x3b/0xd0
[21409.487581]  [<c0245607>] nlm4svc_proc_lock+0x57/0x110
[21409.487656]  [<c03a4740>] svc_process+0x680/0x730
[21409.487731]  [<c0240166>] lockd+0x106/0x240
[21409.487805]  [<c0104b43>] kernel_thread_helper+0x7/0x14
[21409.487880]  =======================



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
