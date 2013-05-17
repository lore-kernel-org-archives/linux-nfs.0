Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw1.transmode.se ([195.58.98.146]:58895 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755056Ab3EQNS5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 May 2013 09:18:57 -0400
In-Reply-To: <OF53E7EB3E.683DA47E-ONC1257B58.0058BE67-C1257B58.005908EA@LocalDomain>
References: <OF6F031A84.8897519B-ONC1257B4E.002D1BA3-C1257B4E.002DBED0@LocalDomain>
				 <OFB2555ACD.CF7424A9-ONC1257B4F.00613A5E-C1257B4F.006908CE@transmode.se>
	 <1366150010.27817.8.camel@leira.trondhjem.org>			 <OF97D68E61.A3C35530-ONC1257B51.0043E567-C1257B51.00450958@LocalDomain>
	 <OFF8AA22C1.D96F08FD-ONC1257B52.003B6FD9-C1257B52.003BEEF9@LocalDomain>
	 <OFAB88709A.0F45CAFB-ONC1257B56.0049D3CA-C1257B56.004AE572@transmode.se>
	 <1366725123.35524.2.camel@leira.trondhjem.org>		 <OF940BEB3A.13ADB6E5-ONC1257B56.004D412D-C1257B56.004E3C54@tran
 <1366726687.35524.6.camel@leira.trondhjem.org>	 <OFDF20F4D8.12606C1E-ONC1257B57.00486945-C1257B57.0048EA91@LocalDomain>
	 <OF036BF424.501B6F08 <1366905541.6812.18.camel@leira.trondhjem.org> <OF53E7EB3E.683DA47E-ONC1257B58.0058BE67-C1257B58.005908EA@LocalDomain>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
MIME-Version: 1.0
Subject: Re: NFS loop on 3.4.39
From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Message-ID: <OF2AAA55C0.A0920F20-ONC1257B6E.0048AE50-C1257B6E.0049244C@transmode.se>
Date: Fri, 17 May 2013 15:18:54 +0200
Content-Type: text/plain; charset="US-ASCII"
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Back on this old problem now with some more input. Upgraded my client to 
3.8.13(server is  on 3.4.44)
and got the NFS4ERR_OLD_STATEID ping pong effect.
Firefox was locked with process state "Dl" and I got this dmesg:

INFO: task mozStorage #2:6355 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mozStorage #2   D f5619280     0  6355      1 0x00000000
 f446d440 00000086 f446d65c f5619280 f3745300 f5619280 ef0da810 c17e4280
 f3745300 c15a897e c17e4280 c17e4280 ef0da810 c17e4280 ef0da810 c17e4280
 f3745300 f3745300 c17e4280 c17e4280 ef0da810 c17e4280 f46124f8 f46124f8
Call Trace:
 [<c15a897e>] ? __schedule+0x23e/0x660
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3a7c>] ? grab_cache_page_write_begin+0x9c/0xe0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c11aea2b>] ? nfs_write_begin+0x5b/0x1c0
 [<c11ae81f>] ? nfs_write_end+0x4f/0x200
 [<c10c2e27>] ? generic_file_buffered_write+0xe7/0x230
 [<c10c478e>] ? __generic_file_aio_write+0x27e/0x500
 [<c15a7fe8>] ? __mutex_lock_slowpath+0x1d8/0x270
 [<c10c4a84>] ? generic_file_aio_write+0x74/0xf0
 [<c11aecc2>] ? nfs_file_write+0x92/0x1c0
 [<c1101a6d>] ? do_sync_write+0xcd/0x110
 [<c1052809>] ? kmap_atomic_prot+0xd9/0x100
 [<c11021fa>] ? rw_verify_area+0x6a/0x130
 [<c11019a0>] ? wait_on_retry_sync_kiocb+0x50/0x50
 [<c1102560>] ? vfs_write+0xa0/0x140
 [<c11018f3>] ? vfs_llseek+0x33/0x40
 [<c1102801>] ? sys_write+0x41/0x80
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
 [<c15a0000>] ? identify_cpu+0xc0/0x36c
INFO: task Gecko_IOThread:10655 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Gecko_IOThread  D 00000000     0 10655   6336 0x00000004
 f44a3400 00000086 ece3dea0 00000000 00000000 c10cb15b ef6fe030 c17e4280
 f30c17c0 ece3de60 c17e4280 c17e4280 ef6fe030 c17e4280 c10cb284 00000002
 0000000e 00000000 00000000 ffffffff 00000000 00000000 f4434638 f4434638
Call Trace:
 [<c10cb15b>] ? tag_pages_for_writeback+0x5b/0xa0
 [<c10cb284>] ? write_cache_pages+0xe4/0x340
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3eae>] ? filemap_fdatawait_range+0xde/0x170
 [<c10c42cb>] ? filemap_write_and_wait_range+0x7b/0x90
 [<c11ae336>] ? nfs_file_fsync+0x36/0xe0
 [<c11ae300>] ? nfs_lock+0x150/0x150
 [<c1125458>] ? vfs_fsync+0x48/0x60
 [<c10fffee>] ? filp_close+0x2e/0x80
 [<c1100094>] ? sys_close+0x54/0xa0
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
INFO: task Gecko_IOThread:10691 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Gecko_IOThread  D 00000000     0 10691   6336 0x00000000
 f44a3400 00000086 d0247ea0 00000000 00000000 c10cb15b ef317400 c17e4280
 f31590c0 d0247e60 c17e4280 c17e4280 ef317400 c17e4280 c10cb284 00000002
 0000000e 00000000 00000000 ffffffff 00000000 00000000 f4434ae8 f4434ae8
Call Trace:
 [<c10cb15b>] ? tag_pages_for_writeback+0x5b/0xa0
 [<c10cb284>] ? write_cache_pages+0xe4/0x340
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3eae>] ? filemap_fdatawait_range+0xde/0x170
 [<c10c42cb>] ? filemap_write_and_wait_range+0x7b/0x90
 [<c11ae336>] ? nfs_file_fsync+0x36/0xe0
 [<c11ae300>] ? nfs_lock+0x150/0x150
 [<c1125458>] ? vfs_fsync+0x48/0x60
 [<c10fffee>] ? filp_close+0x2e/0x80
 [<c1100094>] ? sys_close+0x54/0xa0
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
INFO: task mozStorage #2:6355 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mozStorage #2   D f5619280     0  6355      1 0x00000004
 f446d440 00000086 f446d65c f5619280 f3745300 f5619280 ef0da810 c17e4280
 f3745300 c15a897e c17e4280 c17e4280 ef0da810 c17e4280 ef0da810 c17e4280
 f3745300 f3745300 c17e4280 c17e4280 ef0da810 c17e4280 f46124f8 f46124f8
Call Trace:
 [<c15a897e>] ? __schedule+0x23e/0x660
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3a7c>] ? grab_cache_page_write_begin+0x9c/0xe0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c11aea2b>] ? nfs_write_begin+0x5b/0x1c0
 [<c11ae81f>] ? nfs_write_end+0x4f/0x200
 [<c10c2e27>] ? generic_file_buffered_write+0xe7/0x230
 [<c10c478e>] ? __generic_file_aio_write+0x27e/0x500
 [<c15a7fe8>] ? __mutex_lock_slowpath+0x1d8/0x270
 [<c10c4a84>] ? generic_file_aio_write+0x74/0xf0
 [<c11aecc2>] ? nfs_file_write+0x92/0x1c0
 [<c1101a6d>] ? do_sync_write+0xcd/0x110
 [<c1052809>] ? kmap_atomic_prot+0xd9/0x100
 [<c11021fa>] ? rw_verify_area+0x6a/0x130
 [<c11019a0>] ? wait_on_retry_sync_kiocb+0x50/0x50
 [<c1102560>] ? vfs_write+0xa0/0x140
 [<c11018f3>] ? vfs_llseek+0x33/0x40
 [<c1102801>] ? sys_write+0x41/0x80
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
 [<c15a0000>] ? identify_cpu+0xc0/0x36c
INFO: task Gecko_IOThread:10655 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Gecko_IOThread  D 00000000     0 10655   6355 0x00000004
 f44a3400 00000086 ece3dea0 00000000 00000000 c10cb15b ef6fe030 c17e4280
 f30c17c0 ece3de60 c17e4280 c17e4280 ef6fe030 c17e4280 c10cb284 00000002
 0000000e 00000000 00000000 ffffffff 00000000 00000000 f4434638 f4434638
Call Trace:
 [<c10cb15b>] ? tag_pages_for_writeback+0x5b/0xa0
 [<c10cb284>] ? write_cache_pages+0xe4/0x340
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3eae>] ? filemap_fdatawait_range+0xde/0x170
 [<c10c42cb>] ? filemap_write_and_wait_range+0x7b/0x90
 [<c11ae336>] ? nfs_file_fsync+0x36/0xe0
 [<c11ae300>] ? nfs_lock+0x150/0x150
 [<c1125458>] ? vfs_fsync+0x48/0x60
 [<c10fffee>] ? filp_close+0x2e/0x80
 [<c1100094>] ? sys_close+0x54/0xa0
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
INFO: task Gecko_IOThread:10691 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Gecko_IOThread  D 00000000     0 10691   6355 0x00000000
 f44a3400 00000086 d0247ea0 00000000 00000000 c10cb15b ef317400 c17e4280
 f31590c0 d0247e60 c17e4280 c17e4280 ef317400 c17e4280 c10cb284 00000002
 0000000e 00000000 00000000 ffffffff 00000000 00000000 f4434ae8 f4434ae8
Call Trace:
 [<c10cb15b>] ? tag_pages_for_writeback+0x5b/0xa0
 [<c10cb284>] ? write_cache_pages+0xe4/0x340
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3eae>] ? filemap_fdatawait_range+0xde/0x170
 [<c10c42cb>] ? filemap_write_and_wait_range+0x7b/0x90
 [<c11ae336>] ? nfs_file_fsync+0x36/0xe0
 [<c11ae300>] ? nfs_lock+0x150/0x150
 [<c1125458>] ? vfs_fsync+0x48/0x60
 [<c10fffee>] ? filp_close+0x2e/0x80
 [<c1100094>] ? sys_close+0x54/0xa0
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
INFO: task mozStorage #2:6355 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mozStorage #2   D f5619280     0  6355      1 0x00000004
 f446d440 00000086 f446d65c f5619280 f3745300 f5619280 ef0da810 c17e4280
 f3745300 c15a897e c17e4280 c17e4280 ef0da810 c17e4280 ef0da810 c17e4280
 f3745300 f3745300 c17e4280 c17e4280 ef0da810 c17e4280 f46124f8 f46124f8
Call Trace:
 [<c15a897e>] ? __schedule+0x23e/0x660
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3a7c>] ? grab_cache_page_write_begin+0x9c/0xe0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c11aea2b>] ? nfs_write_begin+0x5b/0x1c0
 [<c11ae81f>] ? nfs_write_end+0x4f/0x200
 [<c10c2e27>] ? generic_file_buffered_write+0xe7/0x230
 [<c10c478e>] ? __generic_file_aio_write+0x27e/0x500
 [<c15a7fe8>] ? __mutex_lock_slowpath+0x1d8/0x270
 [<c10c4a84>] ? generic_file_aio_write+0x74/0xf0
 [<c11aecc2>] ? nfs_file_write+0x92/0x1c0
 [<c1101a6d>] ? do_sync_write+0xcd/0x110
 [<c1052809>] ? kmap_atomic_prot+0xd9/0x100
 [<c11021fa>] ? rw_verify_area+0x6a/0x130
 [<c11019a0>] ? wait_on_retry_sync_kiocb+0x50/0x50
 [<c1102560>] ? vfs_write+0xa0/0x140
 [<c11018f3>] ? vfs_llseek+0x33/0x40
 [<c1102801>] ? sys_write+0x41/0x80
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
 [<c15a0000>] ? identify_cpu+0xc0/0x36c
INFO: task Gecko_IOThread:10655 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Gecko_IOThread  D 00000000     0 10655   6355 0x00000004
 f44a3400 00000086 ece3dea0 00000000 00000000 c10cb15b ef6fe030 c17e4280
 f30c17c0 ece3de60 c17e4280 c17e4280 ef6fe030 c17e4280 c10cb284 00000002
 0000000e 00000000 00000000 ffffffff 00000000 00000000 f4434638 f4434638
Call Trace:
 [<c10cb15b>] ? tag_pages_for_writeback+0x5b/0xa0
 [<c10cb284>] ? write_cache_pages+0xe4/0x340
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3eae>] ? filemap_fdatawait_range+0xde/0x170
 [<c10c42cb>] ? filemap_write_and_wait_range+0x7b/0x90
 [<c11ae336>] ? nfs_file_fsync+0x36/0xe0
 [<c11ae300>] ? nfs_lock+0x150/0x150
 [<c1125458>] ? vfs_fsync+0x48/0x60
 [<c10fffee>] ? filp_close+0x2e/0x80
 [<c1100094>] ? sys_close+0x54/0xa0
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
INFO: task Gecko_IOThread:10691 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Gecko_IOThread  D 00000000     0 10691   6355 0x00000000
 f44a3400 00000086 d0247ea0 00000000 00000000 c10cb15b ef317400 c17e4280
 f31590c0 d0247e60 c17e4280 c17e4280 ef317400 c17e4280 c10cb284 00000002
 0000000e 00000000 00000000 ffffffff 00000000 00000000 f4434ae8 f4434ae8
Call Trace:
 [<c10cb15b>] ? tag_pages_for_writeback+0x5b/0xa0
 [<c10cb284>] ? write_cache_pages+0xe4/0x340
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3eae>] ? filemap_fdatawait_range+0xde/0x170
 [<c10c42cb>] ? filemap_write_and_wait_range+0x7b/0x90
 [<c11ae336>] ? nfs_file_fsync+0x36/0xe0
 [<c11ae300>] ? nfs_lock+0x150/0x150
 [<c1125458>] ? vfs_fsync+0x48/0x60
 [<c10fffee>] ? filp_close+0x2e/0x80
 [<c1100094>] ? sys_close+0x54/0xa0
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
nfsd: last server has exited, flushing export cache
NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
NFSD: starting 90-second grace period
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
INFO: task mozStorage #2:6355 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
mozStorage #2   D f5619280     0  6355      1 0x00000004
 f446d440 00000086 f446d65c f5619280 f3745300 f5619280 ef0da810 c17e4280
 f3745300 c15a897e c17e4280 c17e4280 ef0da810 c17e4280 ef0da810 c17e4280
 f3745300 f3745300 c17e4280 c17e4280 ef0da810 c17e4280 f46124f8 f46124f8
Call Trace:
 [<c15a897e>] ? __schedule+0x23e/0x660
 [<c1088d70>] ? ktime_get_ts+0xf0/0x120
 [<c15a907e>] ? io_schedule+0x6e/0xb0
 [<c10c35f5>] ? sleep_on_page+0x5/0x10
 [<c15a75b5>] ? __wait_on_bit+0x45/0x70
 [<c10c35f0>] ? __lock_page+0x80/0x80
 [<c10c383d>] ? wait_on_page_bit+0x8d/0xa0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c10c3a7c>] ? grab_cache_page_write_begin+0x9c/0xe0
 [<c106ec10>] ? autoremove_wake_function+0x40/0x40
 [<c11aea2b>] ? nfs_write_begin+0x5b/0x1c0
 [<c11ae81f>] ? nfs_write_end+0x4f/0x200
 [<c10c2e27>] ? generic_file_buffered_write+0xe7/0x230
 [<c10c478e>] ? __generic_file_aio_write+0x27e/0x500
 [<c15a7fe8>] ? __mutex_lock_slowpath+0x1d8/0x270
 [<c10c4a84>] ? generic_file_aio_write+0x74/0xf0
 [<c11aecc2>] ? nfs_file_write+0x92/0x1c0
 [<c1101a6d>] ? do_sync_write+0xcd/0x110
 [<c1052809>] ? kmap_atomic_prot+0xd9/0x100
 [<c11021fa>] ? rw_verify_area+0x6a/0x130
 [<c11019a0>] ? wait_on_retry_sync_kiocb+0x50/0x50
 [<c1102560>] ? vfs_write+0xa0/0x140
 [<c11018f3>] ? vfs_llseek+0x33/0x40
 [<c1102801>] ? sys_write+0x41/0x80
 [<c15aa4d8>] ? sysenter_do_call+0x12/0x28
 [<c15a0000>] ? identify_cpu+0xc0/0x36c
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
device eth0 entered promiscuous mode
device eth0 left promiscuous mode

Joakim Tjernlund/Transmode wrote on 2013/04/25 18:12:29:
> 
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote on 2013/04/25 
17:59:01:
> > 
> > On Thu, 2013-04-25 at 17:31 +0200, Joakim Tjernlund wrote:
> > > Joakim Tjernlund/Transmode wrote on 2013/04/24 15:16:26:
> > > > 
> > > > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote on 
2013/04/23 
> > > 16:18:07:
> > > > > 
> > > > > On Tue, 2013-04-23 at 16:14 +0200, Joakim Tjernlund wrote:
> > > > > > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote on 
2013/04/23 
> > > > > > 15:52:06:
> > > > > > > 
> > > > > > > On Tue, 2013-04-23 at 15:38 +0200, Joakim Tjernlund wrote:
> > > > > > > > So, it happened again. Just when hitting search on 
> > > bugs.gentoo.org in 
> > > > > > > > firefox 17.0.3
> > > > > > > > 
> > > > > > > > This time I got a NFS loop with NFS4ERR_BAD_STATEID 
looping over 
> > > and 
> > > > > > over
> > > > > > > > again and FF was hung. Not posting the logs as it does not 

> > > appear to
> > > > > > > > do any good. Nothing in dmesg either.
> > > > > > > > 
> > > > > > > > Noticed this patch on the NFS list:
> > > > > > > >   http://marc.info/?l=linux-nfs&m=136643651710066&w=2
> > > > > > > > I wonder if that could be a potential cure and if so, 
could it 
> > > be
> > > > > > > > backported to 3.4?
> > > > > > > 
> > > > > > > It is in the testing branch on
> > > > > > > 
> > > > > > >   
http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=summary
> > > > > > > 
> > > > > > > if you want to try it out. I'm not planning on backporting 
> > > anything that
> > > > > > > hasn't been labelled with a Cc: stable in that branch.
> > > > > > 
> > > > > > Well, we won't use tip of linus tree in production so there is
> > > > > > little point to use your testing branch. However it looks like 
a 
> > > trivial
> > > > > > backport so I can test it on my client easily.
> > > > > 
> > > > > The point of testing would not be to discover if you can use 
Linus' 
> > > tree
> > > > > in production, but rather to see if the problem is already fixed
> > > > > upstream. If it is, we can bisect to figure out which patch is 
the 
> > > fix.
> > > > > 
> > > > > > Even the NFS server if required, is the above referenced patch 
for
> > > > > > NFS client/server or both? Any chance this is the culprit?
> > > > > 
> > > > > That's a client patch.
> > > 
> > > > Tried 3.4.41+above nfs patch and also 3.8.8, they both have the
> > > > NFS loop problem.
> > > > 
> > > > Now I am at your 
> > > http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=summary, 
> > > > testing branch
> > > > With any luck the error will show soon.
> > > > 
> > > > Question though the loop I see, could it be a NFS server bug ?
> > > > If so it does matter what I do on my client I guess.
> > > 
> > > Ran http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=summary, 
testing 
> > > branch
> > > for a day without problem.
> > > 
> > > Then I backed to 3.4.41 + 
> > >   http://marc.info/?l=linux-nfs&m=136643651710066&w=2 +
> > >   http://marc.info/?l=linux-nfs&m=136674349127504&w=2
> > > this morning, been using all day without problem. It is a good start
> > > but not conclusive yet.
> > > 
> > > Is http://marc.info/?l=linux-nfs&m=136674349127504&w=2 supposed to
> > > fix my type of problem?
> > 
> > No. That's a follow up patch to commit
> > 92b40e93849e29f9ca661de6442bb66282738bf7 (NFSv4: Use the open stateid 
if
> > the delegation has the wrong mode).

> hmm, that commit is the first one I listed, 
http://marc.info/?l=linux-nfs&m=136643651710066&w=2
> and I know that using only that one does NOT fix the problem. I was 
hoping that both of them could
> be the answer?
> 
>  Jocke
