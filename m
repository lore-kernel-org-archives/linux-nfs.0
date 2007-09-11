From: kenneth johansson <ken@kenjo.org>
Subject: Re: lockd loacked in D state
Date: Tue, 11 Sep 2007 09:25:35 +0000 (UTC)
Message-ID: <fc5muf$4gn$1@sea.gmane.org>
References: <fagv4r$v79$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IV207-0000Nx-El
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 02:25:46 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IV20A-0005yN-GN
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 02:25:48 -0700
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1IV205-0002tv-ML
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 11:25:41 +0200
Received: from 1-1-4-20a.ras.sth.bostream.se ([82.182.72.90])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Sep 2007 11:25:41 +0200
Received: from ken by 1-1-4-20a.ras.sth.bostream.se with local (Gmexim 0.1
	(Debian)) id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Sep 2007 11:25:41 +0200
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

It took a lot longer to happen now when I turned on some debugging but 
eventually it got stuck in D state. 

This is from the same run as the lock warning below.

[1728898.928667]  =======================
[1728898.928711] lockd         D 00000002  4840  2432      2 (L-TLB)
[1728898.928853]        e8b91cec 00000046 00000000 00000002 e8b91cd4 c027d948 350fee32 00000046 
[1728898.929134]        00000246 59054ceb 00061f12 00005fb5 e62eb38c eef79660 e62eb3b8 e8b91ce0 
[1728898.929452]        e62eb38c e62eb360 e62eb38c e62eb360 e62eb3b8 e8b91d24 c03365eb e62eb54c 
[1728898.929771] Call Trace:
[1728898.929849]  [<c03365eb>] lock_sock_nested+0x8b/0xf0
[1728898.929924]  [<c0379d2d>] udp_destroy_sock+0xd/0x20
[1728898.929999]  [<c0336d03>] sk_common_release+0x13/0xa0
[1728898.930075]  [<c03791d8>] udp_lib_close+0x8/0x10
[1728898.930149]  [<c03811e7>] inet_release+0x37/0x60
[1728898.930224]  [<c033490b>] sock_release+0x1b/0x70
[1728898.930298]  [<c039f09f>] xs_close+0x8f/0xc0
[1728898.930374]  [<c039f10c>] xs_destroy+0x3c/0x90
[1728898.930449]  [<c039d54c>] xprt_destroy+0x2c/0x50
[1728898.930524]  [<c026cc8b>] kref_put+0x2b/0x90
[1728898.930600]  [<c039d48d>] xprt_put+0xd/0x10
[1728898.930675]  [<c039c3e3>] rpc_destroy_client+0x83/0xd0
[1728898.930750]  [<c039c47a>] rpc_release_client+0x4a/0x70
[1728898.930825]  [<c03a11ab>] rpc_put_task+0x4b/0x80
[1728898.930900]  [<c039c204>] rpc_call_sync+0x74/0xa0
[1728898.930975]  [<c0242d18>] nsm_mon_unmon+0xf8/0x130
[1728898.931051]  [<c0242e2f>] nsm_monitor+0x3f/0xa0
[1728898.931125]  [<c02450e3>] nlm4svc_retrieve_args+0xb3/0xd0
[1728898.931202]  [<c0245607>] nlm4svc_proc_lock+0x57/0x110
[1728898.931278]  [<c03a4740>] svc_process+0x680/0x730
[1728898.931355]  [<c0240166>] lockd+0x106/0x240
[1728898.931434]  [<c0104b43>] kernel_thread_helper+0x7/0x14
[1728898.931509]  =======================






On Wed, 22 Aug 2007 09:20:27 +0000, kenneth johansson wrote:

> Iam running linux 2.6.22.3 on an UP server and after some time lockd
> stops to respond and I need to restart the server.
> 
> I turned on some debugging and got this almost directly. lockd is still
> working at this point.
> 
> I have not tried to decode this printout myself yet. My plan was to wait
> for the next lockup and do a sysrq-t to see where lockd was doing.
> 
> --------------------------

[  369.860677] =======================================================
[  369.860771] [ INFO: possible circular locking dependency detected ]
[  369.860819] 2.6.22.3 #7
[  369.860861] -------------------------------------------------------
[  369.860908] lockd/2432 is trying to acquire lock:
[  369.860953]  (&file->f_mutex){--..}, at: [<c03b723c>] mutex_lock+0x1c/0x20
[  369.861125] 
[  369.861126] but task is already holding lock:
[  369.861207]  (nlm_host_mutex){--..}, at: [<c03b723c>] mutex_lock+0x1c/0x20
[  369.861372] 
[  369.861373] which lock already depends on the new lock.
[  369.861375] 
[  369.861494] 
[  369.861495] the existing dependency chain (in reverse order) is:
[  369.861579] 
[  369.861580] -> #1 (nlm_host_mutex){--..}:
[  369.861748]        [<c0135d4d>] __lock_acquire+0xdad/0xf60
[  369.862028]        [<c0135f55>] lock_acquire+0x55/0x70
[  369.862305]        [<c03b6ff9>] __mutex_lock_slowpath+0x69/0x290
[  369.862583]        [<c03b723c>] mutex_lock+0x1c/0x20
[  369.862858]        [<c023f561>] nlm_lookup_host+0x31/0x310
[  369.863142]        [<c023f874>] nlmsvc_lookup_host+0x34/0x40
[  369.863419]        [<c02414b5>] nlmsvc_lock+0x125/0x360
[  369.863696]        [<c024562c>] nlm4svc_proc_lock+0x7c/0x110
[  369.863976]        [<c03a4740>] svc_process+0x680/0x730
[  369.864257]        [<c0240166>] lockd+0x106/0x240
[  369.864534]        [<c0104b43>] kernel_thread_helper+0x7/0x14
[  369.864813]        [<ffffffff>] 0xffffffff
[  369.865092] 
[  369.865093] -> #0 (&file->f_mutex){--..}:
[  369.865261]        [<c0135bc7>] __lock_acquire+0xc27/0xf60
[  369.865538]        [<c0135f55>] lock_acquire+0x55/0x70
[  369.865813]        [<c03b6ff9>] __mutex_lock_slowpath+0x69/0x290
[  369.866090]        [<c03b723c>] mutex_lock+0x1c/0x20
[  369.866365]        [<c02411c9>] nlmsvc_traverse_blocks+0x29/0xa0
[  369.866644]        [<c02425fe>] nlm_traverse_files+0x6e/0x210
[  369.866920]        [<c024282b>] nlmsvc_mark_resources+0x1b/0x30
[  369.867197]        [<c023f02e>] nlm_gc_hosts+0x4e/0x1e0
[  369.867473]        [<c023f576>] nlm_lookup_host+0x46/0x310
[  369.867750]        [<c023f874>] nlmsvc_lookup_host+0x34/0x40
[  369.868027]        [<c024506b>] nlm4svc_retrieve_args+0x3b/0xd0
[  369.868304]        [<c0245607>] nlm4svc_proc_lock+0x57/0x110
[  369.868580]        [<c03a4740>] svc_process+0x680/0x730
[  369.868856]        [<c0240166>] lockd+0x106/0x240
[  369.869132]        [<c0104b43>] kernel_thread_helper+0x7/0x14
[  369.869408]        [<ffffffff>] 0xffffffff
[  369.869682] 
[  369.869683] other info that might help us debug this:
[  369.869685] 
[  369.869806] 1 lock held by lockd/2432:
[  369.869848]  #0:  (nlm_host_mutex){--..}, at: [<c03b723c>] mutex_lock+0x1c/0x20
[  369.870050] 
[  369.870051] stack backtrace:
[  369.870132]  [<c0104eca>] show_trace_log_lvl+0x1a/0x30
[  369.870207]  [<c0105a02>] show_trace+0x12/0x20
[  369.870282]  [<c0105a75>] dump_stack+0x15/0x20
[  369.870357]  [<c0133d6c>] print_circular_bug_tail+0x6c/0x80
[  369.870433]  [<c0135bc7>] __lock_acquire+0xc27/0xf60
[  369.870508]  [<c0135f55>] lock_acquire+0x55/0x70
[  369.870582]  [<c03b6ff9>] __mutex_lock_slowpath+0x69/0x290
[  369.870658]  [<c03b723c>] mutex_lock+0x1c/0x20
[  369.870732]  [<c02411c9>] nlmsvc_traverse_blocks+0x29/0xa0
[  369.870808]  [<c02425fe>] nlm_traverse_files+0x6e/0x210
[  369.870883]  [<c024282b>] nlmsvc_mark_resources+0x1b/0x30
[  369.870959]  [<c023f02e>] nlm_gc_hosts+0x4e/0x1e0
[  369.871034]  [<c023f576>] nlm_lookup_host+0x46/0x310
[  369.871109]  [<c023f874>] nlmsvc_lookup_host+0x34/0x40
[  369.871185]  [<c024506b>] nlm4svc_retrieve_args+0x3b/0xd0
[  369.871261]  [<c0245607>] nlm4svc_proc_lock+0x57/0x110
[  369.871336]  [<c03a4740>] svc_process+0x680/0x730
[  369.871411]  [<c0240166>] lockd+0x106/0x240
[  369.871486]  [<c0104b43>] kernel_thread_helper+0x7/0x14
[  369.871561]  =======================




-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
