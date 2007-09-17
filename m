From: Jonas Jonsson <jonas@websystem.se>
Subject: Re: Problem with NFS4,
	Error: state recovery failed on NFSv4	 server 192.168.0.1 with
	error 121
Date: Mon, 17 Sep 2007 22:25:33 +0200
Message-ID: <1190060733.5541.14.camel@fry.u7.se>
References: <358c6ad3a55609518d1dfa15ef1f2bd2@imap.u7.se>
	<1190048861.6700.105.camel@heimdal.trondhjem.org>
	<1190049122.6700.108.camel@heimdal.trondhjem.org>
	<1190056357.5541.12.camel@fry.u7.se>
	<1190059068.6700.125.camel@heimdal.trondhjem.org>
Reply-To: jonas@websystem.se
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-y2OdacEKQps3+qNjkHEN"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IXNAp-0000J3-6r
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 13:26:27 -0700
Received: from gonzzor.campus.luth.se ([130.240.199.196] helo=bender.u7.se)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IXNAr-0003hR-6z
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 13:26:32 -0700
In-Reply-To: <1190059068.6700.125.camel@heimdal.trondhjem.org>
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


--=-y2OdacEKQps3+qNjkHEN
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

m=C3=A5n 2007-09-17 klockan 15:57 -0400 skrev Trond Myklebust:
> On Mon, 2007-09-17 at 21:12 +0200, Jonas Jonsson wrote:
> > m=C3=A5n 2007-09-17 klockan 13:12 -0400 skrev Trond Myklebust:
> > > On Mon, 2007-09-17 at 13:07 -0400, Trond Myklebust wrote:
> > > > On Sun, 2007-09-16 at 19:45 +0200, Jonas Jonsson wrote:
> > > >=20
> > > > > Then the ls process hangs and the syslog starts to flodd with
> > > > >=20
> > > > > Error: state recovery failed on NFSv4 server 192.168.0.1 with e=
rror 121
> > > >=20
> > > > Error 121 is EREMOTEIO. That basically means that the server is s=
ick and
> > > > there is little the client can do other than retry in the hope th=
at it
> > > > eventually gets better.
> > > >=20
> > > > What kernel are you using on the server?
> >=20
> > Server:=20
> > Linux bender 2.6.22-gentoo-r5 #2 SMP Fri Sep 14 23:17:31 CEST 2007
> > x86_64 AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ AuthenticAMD
> > GNU/Linux
> >=20
> > Client: (When not testing local)
> > Linux fry 2.6.22-gentoo-r5 #3 SMP Sat Sep 15 01:28:27 CEST 2007 x86_6=
4
> > Intel(R) Core(TM)2 CPU 6400 @ 2.13GHz GenuineIntel GNU/Linux
> >=20
> > > >=20
> > > > > Error: state recovery failed on NFSv4 server 192.168.0.1 with e=
rror 2
> > > >=20
> > > > ENOENT. That means that a file you were reading on the server has
> > > > disappeared while the server was incommunicado.
> > > >=20
> > > > Cheers
> > > >   Trond
> > >=20
> > > BTW: What kind of network connection are you running between the cl=
ient
> > > and server. Is it really that bad that the client is constantly hav=
ing
> > > to recover state?
> >=20
> > I get this error even when I try local on server machine, but between
> > the server and client I have Gbit ehternet connection. The most stran=
ge
> > thing is that I have manage to get reversed situation working.
> >=20
> > I can go on and use ls -la /mnt/nfs as long as I don't stand in the
> > directory, the I get the recovery error. And if I try to read/write t=
o a
> > file I get this error.
> >=20
> > I tried Newpynfs ( http://www.citi.umich.edu/projects/nfsv4/pynfs/ ) =
and
> > with this application I manage to write and read to the server withou=
t
> > the errors, so I'm kind of confused.
> >=20
> > I have also tried a OpenSolaris livecd
> > ( http://www.genunix.org/distributions/belenix_site/ ) with almost sa=
me
> > result, nothing in the logs or so, but the mount command hangs.
> > =20
> > Is there anything else I can try to debug this further?
>=20
> Could you try to trigger the problem on the client, then log in as root
> on the server, and type
>=20
> echo t >/proc/sysrq-trigger
>=20
> and send us the output from 'dmesg -s 90000'?
>=20
> That ought to give us an idea what the server is doing that is causing
> it to hang...
>=20
> Cheers
>   Trond
>=20
Attached the output from dmesg -s 90000

/Jonas

--=-y2OdacEKQps3+qNjkHEN
Content-Disposition: attachment; filename=dmesg_-s_90000
Content-Type: text/plain; name=dmesg_-s_90000; charset=utf-8
Content-Transfer-Encoding: 7bit

ffffff8030dbe1>] __up_read+0x21/0xb0
 [<ffffffff8024b1fd>] do_futex+0x46d/0xc00
 [<ffffffff80439153>] release_sock+0x13/0xb0
 [<ffffffff8048cf35>] inet_accept+0x95/0xd0
 [<ffffffff80279e65>] fd_install+0x25/0x60
 [<ffffffff80438315>] sys_accept+0x1c5/0x1f0
 [<ffffffff804a7ec9>] mutex_lock+0x9/0x20
 [<ffffffff80209a2e>] system_call+0x7e/0x83

pure-ftpd     S 0000000000000001     0 10531      1 (NOTLB)
 ffff8100090b19f8 0000000000000082 0000000000000000 ffffffff8027f940
 ffff8100132f5068 0000000000000000 ffff81001eb5f3e0 ffff81003ff92d40
 00000000002835d2 ffff81001eb5f590 0000000100000006 000000010287d507
Call Trace:
 [<ffffffff8027f940>] inode_sub_bytes+0x20/0x90
 [<ffffffff80244190>] bit_waitqueue+0x10/0xb0
 [<ffffffff804a7bb5>] schedule_timeout+0x95/0xd0
 [<ffffffff8024456c>] add_wait_queue+0x1c/0x60
 [<ffffffff80289ded>] do_select+0x44d/0x540
 [<ffffffff8028a4e0>] __pollwait+0x0/0x130
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff80244190>] bit_waitqueue+0x10/0xb0
 [<ffffffff8027f190>] inode_get_bytes+0x10/0x40
 [<ffffffff802cb8e7>] inode2sd+0xf7/0x120
 [<ffffffff802ddfcf>] pathrelse+0x2f/0x50
 [<ffffffff802cc19b>] reiserfs_update_sd_size+0x22b/0x2c0
 [<ffffffff80244200>] bit_waitqueue+0x80/0xb0
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff802e572c>] do_journal_end+0x2fc/0xdb0
 [<ffffffff8028a0e5>] core_sys_select+0x205/0x300
 [<ffffffff8030dbe1>] __up_read+0x21/0xb0
 [<ffffffff8021dc19>] do_page_fault+0x3c9/0x8c0
 [<ffffffff8028a654>] sys_select+0x44/0x1c0
 [<ffffffff80209a2e>] system_call+0x7e/0x83

distccd       S 0000000000000009     0 22775   5942 (NOTLB)
 ffff81001984fdb8 0000000000000082 0000000000000000 ffff81003fbdf548
 ffff81001984fdc8 ffff810000000000 ffff810028af2d40 ffffffff8058f380
 00000000000564a4 ffff810028af2ef0 0000000000000009 0000000103b573cf
Call Trace:
 [<ffffffff80244278>] wake_up_bit+0x18/0x40
 [<ffffffff804a7bb5>] schedule_timeout+0x95/0xd0
 [<ffffffff804a9139>] _spin_lock_bh+0x9/0x20
 [<ffffffff80439153>] release_sock+0x13/0xb0
 [<ffffffff8046c057>] inet_csk_accept+0x167/0x2a0
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff802a82b8>] inotify_d_instantiate+0x18/0x70
 [<ffffffff8048ced0>] inet_accept+0x30/0xd0
 [<ffffffff8043823f>] sys_accept+0xef/0x1f0
 [<ffffffff8028dbcb>] d_kill+0x4b/0x70
 [<ffffffff8028ea55>] dput+0xa5/0x140
 [<ffffffff8027ceb1>] __fput+0x141/0x1d0
 [<ffffffff802933c7>] mntput_no_expire+0x27/0xa0
 [<ffffffff80209a2e>] system_call+0x7e/0x83

distccd       S 0000000000000009     0 22843   5942 (NOTLB)
 ffff81002d0afdb8 0000000000000082 0000000000000000 ffff81003fbdf548
 ffff81002d0afdc8 ffff810000000000 ffff8100299e2000 ffff81003ff92d40
 0000000000024930 ffff8100299e21b0 0000000100000004 0000000103b573eb
Call Trace:
 [<ffffffff80244278>] wake_up_bit+0x18/0x40
 [<ffffffff804a7bb5>] schedule_timeout+0x95/0xd0
 [<ffffffff804a9139>] _spin_lock_bh+0x9/0x20
 [<ffffffff80439153>] release_sock+0x13/0xb0
 [<ffffffff8046c057>] inet_csk_accept+0x167/0x2a0
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff802a82b8>] inotify_d_instantiate+0x18/0x70
 [<ffffffff8048ced0>] inet_accept+0x30/0xd0
 [<ffffffff8043823f>] sys_accept+0xef/0x1f0
 [<ffffffff8028dbcb>] d_kill+0x4b/0x70
 [<ffffffff8028ea55>] dput+0xa5/0x140
 [<ffffffff8027ceb1>] __fput+0x141/0x1d0
 [<ffffffff802933c7>] mntput_no_expire+0x27/0xa0
 [<ffffffff80209a2e>] system_call+0x7e/0x83

distccd       S 0000000000000009     0 22895   5942 (NOTLB)
 ffff810012087db8 0000000000000086 0000000000000000 ffff81003fbdf548
 ffff810012087dc8 ffff810000000000 ffff8100299e33e0 ffff81003ff92d40
 000000000007c20e ffff8100299e3590 0000000100000009 0000000103b57366
Call Trace:
 [<ffffffff80244278>] wake_up_bit+0x18/0x40
 [<ffffffff804a7bb5>] schedule_timeout+0x95/0xd0
 [<ffffffff804a9139>] _spin_lock_bh+0x9/0x20
 [<ffffffff80439153>] release_sock+0x13/0xb0
 [<ffffffff8046c057>] inet_csk_accept+0x167/0x2a0
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff802a82b8>] inotify_d_instantiate+0x18/0x70
 [<ffffffff8048ced0>] inet_accept+0x30/0xd0
 [<ffffffff8043823f>] sys_accept+0xef/0x1f0
 [<ffffffff8028dbcb>] d_kill+0x4b/0x70
 [<ffffffff8028ea55>] dput+0xa5/0x140
 [<ffffffff8027ceb1>] __fput+0x141/0x1d0
 [<ffffffff802933c7>] mntput_no_expire+0x27/0xa0
 [<ffffffff80209a2e>] system_call+0x7e/0x83

distccd       S 0000000000000009     0 23065   5942 (NOTLB)
 ffff810035c95db8 0000000000000086 0000000000000000 ffff81003fbdf548
 ffff810035c95dc8 ffff810000000000 ffff81003728e000 ffff81003ff92d40
 0000000000088244 ffff81003728e1b0 0000000100000004 0000000103b57346
Call Trace:
 [<ffffffff80244278>] wake_up_bit+0x18/0x40
 [<ffffffff804a7bb5>] schedule_timeout+0x95/0xd0
 [<ffffffff804a9139>] _spin_lock_bh+0x9/0x20
 [<ffffffff80439153>] release_sock+0x13/0xb0
 [<ffffffff8046c057>] inet_csk_accept+0x167/0x2a0
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff802a82b8>] inotify_d_instantiate+0x18/0x70
 [<ffffffff8048ced0>] inet_accept+0x30/0xd0
 [<ffffffff8043823f>] sys_accept+0xef/0x1f0
 [<ffffffff8028dbcb>] d_kill+0x4b/0x70
 [<ffffffff8028ea55>] dput+0xa5/0x140
 [<ffffffff8027ceb1>] __fput+0x141/0x1d0
 [<ffffffff802933c7>] mntput_no_expire+0x27/0xa0
 [<ffffffff80209a2e>] system_call+0x7e/0x83

imap-login    S 00000000000000fa     0 23764   4829 (NOTLB)
 ffff810006875e78 0000000000000082 0000000000000000 0000000000000000
 0000000d00000097 ffff810000000000 ffff810014474000 ffff810014b5b3e0
 000000000000449a ffff8100144741b0 0000000100000286 ffffffff80239004
Call Trace:
 [<ffffffff80239004>] lock_timer_base+0x34/0x70
 [<ffffffff80239176>] __mod_timer+0xb6/0xd0
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff802a93b8>] sys_epoll_wait+0x178/0x4d0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff80209a2e>] system_call+0x7e/0x83

imap-login    S 000000000000000a     0 24351   4829 (NOTLB)
 ffff810002d8de78 0000000000000086 0000000000000000 0000000000000000
 ffff8100817f3000 ffff810000000000 ffff81001e1f66a0 ffff81003ff92d40
 0000000000003409 ffff81001e1f6850 0000000100000286 0000000103c2f334
Call Trace:
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff802a93b8>] sys_epoll_wait+0x178/0x4d0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff80209a2e>] system_call+0x7e/0x83

imap-login    S 00000000000000fa     0 24987   4829 (NOTLB)
 ffff8100310f1e78 0000000000000086 0000000000000000 0000000000000000
 ffff8100817f3000 ffff810000000000 ffff8100312b8000 ffff810014b5b3e0
 00000000000043ca ffff8100312b81b0 0000000100000286 ffffffff80239004
Call Trace:
 [<ffffffff80239004>] lock_timer_base+0x34/0x70
 [<ffffffff80239176>] __mod_timer+0xb6/0xd0
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff802a93b8>] sys_epoll_wait+0x178/0x4d0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff80209a2e>] system_call+0x7e/0x83

imap          S 000000000000000a     0 25035   4829 (NOTLB)
 ffff810019759e78 0000000000000082 0000000000000000 ffffffff8027baf9
 ffff810006dcd000 ffffffff00000000 ffff8100306cc000 ffff81003ff92d40
 0000000000004da7 ffff8100306cc1b0 0000000100000286 0000000103c2f1da
Call Trace:
 [<ffffffff8027baf9>] do_sync_write+0xd9/0x120
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff802a93b8>] sys_epoll_wait+0x178/0x4d0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff80209a2e>] system_call+0x7e/0x83

imap-login    S 00000000000000fa     0 25036   4829 (NOTLB)
 ffff810033fa3e78 0000000000000082 0000000000000000 0000000000000000
 00000000249a53f8 0000000000000000 ffff8100306cc6a0 ffff810039d24d40
 0000000000003351 ffff8100306cc850 0000000100000286 ffffffff80239004
Call Trace:
 [<ffffffff80239004>] lock_timer_base+0x34/0x70
 [<ffffffff80239176>] __mod_timer+0xb6/0xd0
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff802a93b8>] sys_epoll_wait+0x178/0x4d0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff80209a2e>] system_call+0x7e/0x83

pickup        S 000000000000000a     0 29714   5187 (NOTLB)
 ffff81000f5859f8 0000000000000082 0000000000000000 ffff81001f1663f0
 ffff81000f585b20 ffff810000000000 ffff8100312b86a0 ffff81003ff92d40
 00000000000004a8 ffff8100312b8850 0000000100000286 0000000103c2d1ca
Call Trace:
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff80289ded>] do_select+0x44d/0x540
 [<ffffffff8028a4e0>] __pollwait+0x0/0x130
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff80439611>] sock_alloc_send_skb+0x191/0x1f0
 [<ffffffff80439611>] sock_alloc_send_skb+0x191/0x1f0
 [<ffffffff802279f7>] __wake_up_common+0x47/0x70
 [<ffffffff80228053>] __wake_up+0x43/0x70
 [<ffffffff8043af91>] sock_def_readable+0x61/0x70
 [<ffffffff804a2a1f>] unix_stream_sendmsg+0x1af/0x380
 [<ffffffff804361e5>] sock_aio_write+0x115/0x130
 [<ffffffff8028a0e5>] core_sys_select+0x205/0x300
 [<ffffffff80248229>] getnstimeofday+0x39/0xa0
 [<ffffffff80248229>] getnstimeofday+0x39/0xa0
 [<ffffffff80247111>] ktime_get_ts+0x21/0x60
 [<ffffffff8030d53a>] rb_insert_color+0x8a/0xf0
 [<ffffffff80246a77>] enqueue_hrtimer+0x67/0x70
 [<ffffffff80246e5e>] hrtimer_start+0xde/0x150
 [<ffffffff8028a6e1>] sys_select+0xd1/0x1c0
 [<ffffffff80209a2e>] system_call+0x7e/0x83

sshd          S 7fffffffffffffff     0 29781   4644 (NOTLB)
 ffff810032293bf8 0000000000000086 ffff81001f83ca00 ffffffff8043af40
 ffff81001f83ca00 ffffffff804a2a1f ffff810036eac000 ffff81001f4b93e0
 0000000000000262 ffff810036eac1b0 0000000132293d18 ffff810010106a00
Call Trace:
 [<ffffffff8043af40>] sock_def_readable+0x10/0x70
 [<ffffffff804a2a1f>] unix_stream_sendmsg+0x1af/0x380
 [<ffffffff8028e447>] __d_lookup+0x97/0x120
 [<ffffffff804a7bb5>] schedule_timeout+0x95/0xd0
 [<ffffffff80244433>] prepare_to_wait+0x23/0x80
 [<ffffffff804a1d81>] unix_stream_recvmsg+0x391/0x580
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff80436316>] sock_aio_read+0x116/0x120
 [<ffffffff80286639>] do_path_lookup+0x89/0x1f0
 [<ffffffff8027bc19>] do_sync_read+0xd9/0x120
 [<ffffffff802876e9>] open_namei+0x99/0x6a0
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff8027a1c1>] __dentry_open+0x1a1/0x220
 [<ffffffff8027a34a>] do_filp_open+0x3a/0x50
 [<ffffffff8027c5b7>] vfs_read+0x157/0x160
 [<ffffffff8027ca03>] sys_read+0x53/0x90
 [<ffffffff80209a2e>] system_call+0x7e/0x83

sshd          S 7fffffffffffffff     0 29784  29781 (NOTLB)
 ffff8100221bb9f8 0000000000000086 ffffffff80455ae9 ffff81001f166bd0
 ffff8100221bbb20 ffff810007351b50 ffff81001f4b93e0 ffff81003a7746a0
 0000000000007520 ffff81001f4b9590 0000000100000000 ffffffff805a5b10
Call Trace:
 [<ffffffff80455ae9>] __nf_conntrack_find+0x19/0x130
 [<ffffffff80228053>] __wake_up+0x43/0x70
 [<ffffffff804a7bb5>] schedule_timeout+0x95/0xd0
 [<ffffffff80324871>] tty_poll+0x91/0xa0
 [<ffffffff80289ded>] do_select+0x44d/0x540
 [<ffffffff8028a4e0>] __pollwait+0x0/0x130
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8043930f>] sk_reset_timer+0xf/0x20
 [<ffffffff8047a900>] __tcp_push_pending_frames+0x130/0x950
 [<ffffffff8046ee07>] tcp_sendmsg+0x597/0xc20
 [<ffffffff804a9139>] _spin_lock_bh+0x9/0x20
 [<ffffffff80439153>] release_sock+0x13/0xb0
 [<ffffffff8046f0a0>] tcp_sendmsg+0x830/0xc20
 [<ffffffff804361e5>] sock_aio_write+0x115/0x130
 [<ffffffff8028a0e5>] core_sys_select+0x205/0x300
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8023500b>] current_fs_time+0x3b/0x40
 [<ffffffff80323251>] tty_ldisc_deref+0x51/0x80
 [<ffffffff8028a654>] sys_select+0x44/0x1c0
 [<ffffffff8027ca93>] sys_write+0x53/0x90
 [<ffffffff80209a2e>] system_call+0x7e/0x83

bash          S ffff8100306cd4f0     0 29785  29784 (NOTLB)
 ffff81003a387ec8 0000000000000082 0000000000000000 ffff81002e771f18
 0000000000000292 ffffffff8030dbe1 ffff810009046d40 ffff8100306cd3e0
 0000000000018c91 ffff810009046ef0 0000000100000000 ffff81003867f800
Call Trace:
 [<ffffffff8030dbe1>] __up_read+0x21/0xb0
 [<ffffffff80228053>] __wake_up+0x43/0x70
 [<ffffffff80232c38>] do_wait+0x728/0xc70
 [<ffffffff80288c04>] vfs_ioctl+0x74/0x2d0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff80288ea9>] sys_ioctl+0x49/0x80
 [<ffffffff80209a2e>] system_call+0x7e/0x83

portmap       S 7fffffffffffffff     0 29884      1 (NOTLB)
 ffff8100360c3b18 0000000000000082 ffff81003dbca410 ffff81000c430300
 ffff810003ed9780 ffff81003dbca410 ffff8100393d33e0 ffff81000dc773e0
 0000000000016667 ffff8100393d3590 0000000138032e00 ffff810038032e00
Call Trace:
 [<ffffffff8048465a>] udp_push_pending_frames+0x14a/0x370
 [<ffffffff804a7bb5>] schedule_timeout+0x95/0xd0
 [<ffffffff8043fb85>] datagram_poll+0x105/0x110
 [<ffffffff8024456c>] add_wait_queue+0x1c/0x60
 [<ffffffff802897d2>] do_sys_poll+0x2a2/0x420
 [<ffffffff8028a4e0>] __pollwait+0x0/0x130
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff8025bd1a>] get_page_from_freelist+0x2ba/0x3b0
 [<ffffffff8043606e>] move_addr_to_kernel+0x2e/0x40
 [<ffffffff8043f1bf>] verify_iovec+0x2f/0xa0
 [<ffffffff80437087>] sys_sendmsg+0x1d7/0x360
 [<ffffffff80268730>] unmap_region+0x150/0x160
 [<ffffffff8026878c>] remove_vma+0x4c/0x60
 [<ffffffff80289983>] sys_poll+0x33/0x50
 [<ffffffff80209a2e>] system_call+0x7e/0x83

rpc.statd     S 0000000000000005     0 29952      1 (NOTLB)
 ffff8100266e59f8 0000000000000086 0000000000000000 ffff810001e17a18
 ffff8100266e5ac8 ffff810000000000 ffff810014474d40 ffffffff8058f380
 000000000000d369 ffff810014474ef0 0000000000000000 0000000103c27adf
Call Trace:
 [<ffffffff804a7bb5>] schedule_timeout+0x95/0xd0
 [<ffffffff8043fb85>] datagram_poll+0x105/0x110
 [<ffffffff8024456c>] add_wait_queue+0x1c/0x60
 [<ffffffff80289ded>] do_select+0x44d/0x540
 [<ffffffff8028a4e0>] __pollwait+0x0/0x130
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8028e447>] __d_lookup+0x97/0x120
 [<ffffffff80244190>] bit_waitqueue+0x10/0xb0
 [<ffffffff8027f190>] inode_get_bytes+0x10/0x40
 [<ffffffff802cb8e7>] inode2sd+0xf7/0x120
 [<ffffffff802ddfcf>] pathrelse+0x2f/0x50
 [<ffffffff802cc19b>] reiserfs_update_sd_size+0x22b/0x2c0
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff802e572c>] do_journal_end+0x2fc/0xdb0
 [<ffffffff80244200>] bit_waitqueue+0x80/0xb0
 [<ffffffff8028a0e5>] core_sys_select+0x205/0x300
 [<ffffffff8030dbe1>] __up_read+0x21/0xb0
 [<ffffffff8021dc19>] do_page_fault+0x3c9/0x8c0
 [<ffffffff80291dfa>] notify_change+0x1ba/0x2e0
 [<ffffffff8028a654>] sys_select+0x44/0x1c0
 [<ffffffff8023d6fa>] set_user+0x4a/0xb0
 [<ffffffff80209a2e>] system_call+0x7e/0x83

rpc.mountd    S 000000000000000a     0 29982      1 (NOTLB)
 ffff81003e05d9f8 0000000000000082 0000000000000000 ffffffff8027f940
 ffff810023e7dc98 0000000000000000 ffff8100332113e0 ffff81003ff92d40
 0000000000000752 ffff810033211590 0000000100000000 0000000103c2c355
Call Trace:
 [<ffffffff8027f940>] inode_sub_bytes+0x20/0x90
 [<ffffffff80244190>] bit_waitqueue+0x10/0xb0
 [<ffffffff804a7bb5>] schedule_timeout+0x95/0xd0
 [<ffffffff8043fb85>] datagram_poll+0x105/0x110
 [<ffffffff804842e3>] udp_poll+0x13/0x130
 [<ffffffff80289ded>] do_select+0x44d/0x540
 [<ffffffff8028a4e0>] __pollwait+0x0/0x130
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff80228053>] __wake_up+0x43/0x70
 [<ffffffff8802174f>] :sunrpc:svc_sock_enqueue+0x19f/0x340
 [<ffffffff80235373>] local_bh_enable_ip+0x53/0x60
 [<ffffffff88023c90>] :sunrpc:svc_revisit+0xd0/0x180
 [<ffffffff88027e16>] :sunrpc:cache_revisit_request+0x36/0x110
 [<ffffffff8028a0e5>] core_sys_select+0x205/0x300
 [<ffffffff8030dbe1>] __up_read+0x21/0xb0
 [<ffffffff804a6bcb>] thread_return+0x0/0x6b5
 [<ffffffff8028a654>] sys_select+0x44/0x1c0
 [<ffffffff8027ca93>] sys_write+0x53/0x90
 [<ffffffff80209a2e>] system_call+0x7e/0x83

nfsd4         S 000000000000000a     0 29984      2 (L-TLB)
 ffff81002e2b3ec0 0000000000000046 0000000000000000 ffffffff880863a0
 00000000000057e4 0000000000000000 ffff8100390813e0 ffffffff8058f380
 0000000000007644 ffff810039081590 000000008808f690 0000000103c2d2fe
Call Trace:
 [<ffffffff88071b16>] :nfsd:laundromat_main+0x266/0x2b0
 [<ffffffff80240bc0>] worker_thread+0x0/0x130
 [<ffffffff80240cc5>] worker_thread+0x105/0x130
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff80240bc0>] worker_thread+0x0/0x130
 [<ffffffff80240bc0>] worker_thread+0x0/0x130
 [<ffffffff80243edb>] kthread+0x4b/0x80
 [<ffffffff8020a848>] child_rip+0xa/0x12
 [<ffffffff80243e90>] kthread+0x0/0x80
 [<ffffffff8020a83e>] child_rip+0x0/0x12

lockd         S 0000000000000001     0 29987      2 (L-TLB)
 ffff81000c445e10 0000000000000046 0000000000000000 ffff81000c445d60
 ffff81003e3f26a0 0000000000000000 ffff8100217bc000 ffffffff8058f380
 0000000000003ada ffff8100217bc1b0 000000000c445dc0 0000000103c27b1a
Call Trace:
 [<ffffffff804a7bb5>] schedule_timeout+0x95/0xd0
 [<ffffffff8802229d>] :sunrpc:svc_sock_release+0xdd/0x1a0
 [<ffffffff8024456c>] add_wait_queue+0x1c/0x60
 [<ffffffff88023f8e>] :sunrpc:svc_recv+0x24e/0x4e0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8024078e>] __create_workqueue+0x17e/0x190
 [<ffffffff88045ae0>] :lockd:lockd+0x0/0x2d0
 [<ffffffff88045c14>] :lockd:lockd+0x134/0x2d0
 [<ffffffff8020a848>] child_rip+0xa/0x12
 [<ffffffff88045ae0>] :lockd:lockd+0x0/0x2d0
 [<ffffffff88045ae0>] :lockd:lockd+0x0/0x2d0
 [<ffffffff8020a83e>] child_rip+0x0/0x12

rpciod/0      S ffff81002916c718     0 29988      2 (L-TLB)
 ffff810020af1ec0 0000000000000046 ffff810020af1e30 ffffffff80227c72
 0000000000000001 0000000000000000 ffff81003728f3e0 ffff81003e3f26a0
 000000000000065a ffff81003728f590 000000000000000a ffffffff804a6bcb
Call Trace:
 [<ffffffff80227c72>] __activate_task+0x32/0x50
 [<ffffffff804a6bcb>] thread_return+0x0/0x6b5
 [<ffffffff80240bc0>] worker_thread+0x0/0x130
 [<ffffffff80240cc5>] worker_thread+0x105/0x130
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff80240bc0>] worker_thread+0x0/0x130
 [<ffffffff80240bc0>] worker_thread+0x0/0x130
 [<ffffffff80243edb>] kthread+0x4b/0x80
 [<ffffffff8020a848>] child_rip+0xa/0x12
 [<ffffffff80243e90>] kthread+0x0/0x80
 [<ffffffff8020a83e>] child_rip+0x0/0x12

rpciod/1      S ffff81002916c618     0 29989      2 (L-TLB)
 ffff81001c5c1ec0 0000000000000046 ffff81001c5c1e30 ffffffff80227c72
 0000000000000001 0000000000000000 ffff81003e3f26a0 ffff81000dc773e0
 00000000000008d5 ffff81003e3f2850 000000010000000a ffffffff804a6bcb
Call Trace:
 [<ffffffff80227c72>] __activate_task+0x32/0x50
 [<ffffffff804a6bcb>] thread_return+0x0/0x6b5
 [<ffffffff80240bc0>] worker_thread+0x0/0x130
 [<ffffffff80240cc5>] worker_thread+0x105/0x130
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff80240bc0>] worker_thread+0x0/0x130
 [<ffffffff80240bc0>] worker_thread+0x0/0x130
 [<ffffffff80243edb>] kthread+0x4b/0x80
 [<ffffffff8020a848>] child_rip+0xa/0x12
 [<ffffffff80243e90>] kthread+0x0/0x80
 [<ffffffff8020a83e>] child_rip+0x0/0x12

nfsd          S 00000000000dbba0     0 29990      2 (L-TLB)
 ffff810015701e30 0000000000000046 0000000000000080 ffff810016361c00
 ffff810030ed82c0 00000000fffffff5 ffff8100312b93e0 ffff810037e76000
 0000000000003606 ffff8100312b9590 0000000100000286 ffffffff80239004
Call Trace:
 [<ffffffff80239004>] lock_timer_base+0x34/0x70
 [<ffffffff80239176>] __mod_timer+0xb6/0xd0
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff88023f8e>] :sunrpc:svc_recv+0x24e/0x4e0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff88058851>] :nfsd:nfsd+0xd1/0x2e0
 [<ffffffff8020a848>] child_rip+0xa/0x12
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff8020a83e>] child_rip+0x0/0x12

nfsd          S 00000000000dbba0     0 29991      2 (L-TLB)
 ffff810004101e30 0000000000000046 ffff810004101db8 ffff810016361c00
 ffff810037852580 0000000000000000 ffff810037e76000 ffff810036ead3e0
 0000000000000f7b ffff810037e761b0 0000000100000286 ffffffff80239004
Call Trace:
 [<ffffffff80239004>] lock_timer_base+0x34/0x70
 [<ffffffff80239176>] __mod_timer+0xb6/0xd0
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff88023f8e>] :sunrpc:svc_recv+0x24e/0x4e0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff88058851>] :nfsd:nfsd+0xd1/0x2e0
 [<ffffffff8020a848>] child_rip+0xa/0x12
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff8020a83e>] child_rip+0x0/0x12

nfsd          S 00000000000dbba0     0 29992      2 (L-TLB)
 ffff810030147e30 0000000000000046 0000000000000000 ffff810016361c00
 ffff810037852000 0000000000000000 ffff810036ead3e0 ffff810036eacd40
 0000000000000d15 ffff810036ead590 0000000100000286 ffffffff80239004
Call Trace:
 [<ffffffff80239004>] lock_timer_base+0x34/0x70
 [<ffffffff80239176>] __mod_timer+0xb6/0xd0
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff88023f8e>] :sunrpc:svc_recv+0x24e/0x4e0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff88058851>] :nfsd:nfsd+0xd1/0x2e0
 [<ffffffff8020a848>] child_rip+0xa/0x12
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff8020a83e>] child_rip+0x0/0x12

nfsd          S 00000000000dbba0     0 29993      2 (L-TLB)
 ffff81000c667e30 0000000000000046 00002b7ba33ce468 ffff810016361c00
 ffff81003e20a2c0 0000000000000000 ffff810036eacd40 ffff81000dc773e0
 0000000000001080 ffff810036eacef0 0000000100000286 ffffffff80239004
Call Trace:
 [<ffffffff80239004>] lock_timer_base+0x34/0x70
 [<ffffffff80239176>] __mod_timer+0xb6/0xd0
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff88023f8e>] :sunrpc:svc_recv+0x24e/0x4e0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff88058851>] :nfsd:nfsd+0xd1/0x2e0
 [<ffffffff8020a848>] child_rip+0xa/0x12
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff8020a83e>] child_rip+0x0/0x12

nfsd          S 00000000000dbba0     0 29994      2 (L-TLB)
 ffff810015c13e30 0000000000000046 0000000000000000 ffff810016361c00
 ffff81003e20b340 0000000000000000 ffff8100035753e0 ffff810003574d40
 0000000000003104 ffff810003575590 0000000100000286 ffffffff80239004
Call Trace:
 [<ffffffff80239004>] lock_timer_base+0x34/0x70
 [<ffffffff80239176>] __mod_timer+0xb6/0xd0
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff88023f8e>] :sunrpc:svc_recv+0x24e/0x4e0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff88058851>] :nfsd:nfsd+0xd1/0x2e0
 [<ffffffff8020a848>] child_rip+0xa/0x12
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff8020a83e>] child_rip+0x0/0x12

nfsd          R  running task       0 29995      2 (L-TLB)
nfsd          S 00000000000dbba0     0 29996      2 (L-TLB)
 ffff810003bbbe30 0000000000000046 0000000000000000 ffff810016361c00
 ffff81002df5f080 0000000000000212 ffff81001687c6a0 ffff810014b5b3e0
 0000000000002f71 ffff81001687c850 0000000100000286 ffffffff80239004
Call Trace:
 [<ffffffff80239004>] lock_timer_base+0x34/0x70
 [<ffffffff80239176>] __mod_timer+0xb6/0xd0
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff88023f8e>] :sunrpc:svc_recv+0x24e/0x4e0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff804a8b62>] __down_read+0x12/0xb0
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff88058851>] :nfsd:nfsd+0xd1/0x2e0
 [<ffffffff8020a848>] child_rip+0xa/0x12
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff8020a83e>] child_rip+0x0/0x12

nfsd          S 00000000000dbba0     0 29997      2 (L-TLB)
 ffff81002abd3e30 0000000000000046 ffff81002abd3db0 ffffffff88072c72
 00000000000dbba0 0000000000000212 ffff810014b5b3e0 ffff810003574d40
 0000000000002e96 ffff810014b5b590 0000000100000286 ffffffff80239004
Call Trace:
 [<ffffffff88072c72>] :nfsd:nfsd4_setclientid+0xf2/0x3b0
 [<ffffffff80239004>] lock_timer_base+0x34/0x70
 [<ffffffff80239176>] __mod_timer+0xb6/0xd0
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff88023f8e>] :sunrpc:svc_recv+0x24e/0x4e0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff804a8b62>] __down_read+0x12/0xb0
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff88058851>] :nfsd:nfsd+0xd1/0x2e0
 [<ffffffff8020a848>] child_rip+0xa/0x12
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff88058780>] :nfsd:nfsd+0x0/0x2e0
 [<ffffffff8020a83e>] child_rip+0x0/0x12

rpc.idmapd    S 000000000000000a     0 30062      1 (NOTLB)
 ffff81003aad5e78 0000000000000086 0000000000000000 00ffffff00ffffff
 00ffffff00ffffff 00ffffff00000000 ffff8100306ccd40 ffffffff8058f380
 0000000000004559 ffff8100306ccef0 0000000000000282 0000000103c2ef48
Call Trace:
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff802a93b8>] sys_epoll_wait+0x178/0x4d0
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8023c730>] sys_rt_sigprocmask+0x80/0x100
 [<ffffffff80209a2e>] system_call+0x7e/0x83

su            S 0000000000000008     0 30071  29785 (NOTLB)
 ffff810024973ec8 0000000000000082 0000000000000000 ffff81003812adc8
 0000000000000292 ffffffff00000000 ffff8100306cd3e0 ffffffff8058f380
 000000000000a68c ffff8100306cd590 0000000041b96b70 0000000103c2ddfb
Call Trace:
 [<ffffffff80232c38>] do_wait+0x728/0xc70
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff80209a2e>] system_call+0x7e/0x83

bash          R  running task       0 30072  30071 (NOTLB)
cron          S 0000000000000007     0 30080   5377 (NOTLB)
 ffff810016f09cd8 0000000000000086 0000000000000000 ffffffff80536fa6
 0000000000000002 0000000b00000000 ffff810039080d40 ffffffff8058f380
 0000000000003b6d ffff810039080ef0 0000000000000001 0000000103c2f2fd
Call Trace:
 [<ffffffff804a93ed>] error_exit+0x0/0x84
 [<ffffffff802827c2>] pipe_wait+0x82/0xb0
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff80282ecf>] pipe_read+0xef/0x450
 [<ffffffff8027bc19>] do_sync_read+0xd9/0x120
 [<ffffffff8030dbe1>] __up_read+0x21/0xb0
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff804a6bcb>] thread_return+0x0/0x6b5
 [<ffffffff8027c525>] vfs_read+0xc5/0x160
 [<ffffffff8027ca03>] sys_read+0x53/0x90
 [<ffffffff80209a2e>] system_call+0x7e/0x83

sh            S ffff810011e22110     0 30082  30080 (NOTLB)
 ffff810023f7fec8 0000000000000086 ffff8100162fda60 ffff81001bf74930
 0000000000000292 ffffffff8030dbe1 ffff8100233286a0 ffff81003ff853e0
 00000000000133ed ffff810023328850 00000000d0918e30 0000000000000000
Call Trace:
 [<ffffffff8030dbe1>] __up_read+0x21/0xb0
 [<ffffffff80232c38>] do_wait+0x728/0xc70
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff80209a2e>] system_call+0x7e/0x83

getmail       S 000000000000000a     0 30085  30082 (NOTLB)
 ffff810021239b18 0000000000000086 0000000000000000 ffff8100141845c0
 0000000000000000 0000000000000000 ffff810011e22000 ffff81003ff92d40
 0000000000009983 ffff810011e221b0 0000000100000286 0000000103c2f3b3
Call Trace:
 [<ffffffff804a7b7f>] schedule_timeout+0x5f/0xd0
 [<ffffffff80238ec0>] process_timeout+0x0/0x10
 [<ffffffff802897d2>] do_sys_poll+0x2a2/0x420
 [<ffffffff8028a4e0>] __pollwait+0x0/0x130
 [<ffffffff8022a810>] default_wake_function+0x0/0x10
 [<ffffffff8046f0a0>] tcp_sendmsg+0x830/0xc20
 [<ffffffff80436e7b>] sock_sendmsg+0xcb/0x100
 [<ffffffff80436d85>] sock_recvmsg+0xd5/0x100
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff80286639>] do_path_lookup+0x89/0x1f0
 [<ffffffff802933c7>] mntput_no_expire+0x27/0xa0
 [<ffffffff8027f497>] cp_new_stat+0xe7/0x100
 [<ffffffff80437356>] sys_sendto+0x146/0x1b0
 [<ffffffff80289983>] sys_poll+0x33/0x50
 [<ffffffff80209a2e>] system_call+0x7e/0x83

sendmail      S ffff810037fca000     0 30095  30080 (NOTLB)
 ffff810000e99cd8 0000000000000086 0000000000000292 ffffffff8043cab2
 ffff810000c31280 ffff810038b75100 ffff8100217bd3e0 ffff81000ba6a000
 000000000000a770 ffff8100217bd590 0000000100c314e4 ffff810000c31330
Call Trace:
 [<ffffffff8043cab2>] skb_dequeue+0x52/0x70
 [<ffffffff802827c2>] pipe_wait+0x82/0xb0
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff80282ecf>] pipe_read+0xef/0x450
 [<ffffffff8027bc19>] do_sync_read+0xd9/0x120
 [<ffffffff8030dbe1>] __up_read+0x21/0xb0
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff804a6bcb>] thread_return+0x0/0x6b5
 [<ffffffff8027c525>] vfs_read+0xc5/0x160
 [<ffffffff8027ca03>] sys_read+0x53/0x90
 [<ffffffff80209a2e>] system_call+0x7e/0x83

postdrop      S 0000000000000005     0 30096  30095 (NOTLB)
 ffff8100309bfbf8 0000000000000082 0000000000000000 ffff8100217bd3e0
 0000000000000082 ffffffff00000000 ffff81000ba6a000 ffff81003ff92d40
 000000000000232e ffff81000ba6a1b0 0000000100000020 0000000103c2f315
Call Trace:
 [<ffffffff80439611>] sock_alloc_send_skb+0x191/0x1f0
 [<ffffffff804a7bb5>] schedule_timeout+0x95/0xd0
 [<ffffffff80244433>] prepare_to_wait+0x23/0x80
 [<ffffffff804a1d81>] unix_stream_recvmsg+0x391/0x580
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff8025bd1a>] get_page_from_freelist+0x2ba/0x3b0
 [<ffffffff80436316>] sock_aio_read+0x116/0x120
 [<ffffffff8027bc19>] do_sync_read+0xd9/0x120
 [<ffffffff8030dbe1>] __up_read+0x21/0xb0
 [<ffffffff802442a0>] autoremove_wake_function+0x0/0x30
 [<ffffffff804a6bcb>] thread_return+0x0/0x6b5
 [<ffffffff8027c5b7>] vfs_read+0x157/0x160
 [<ffffffff8027ca03>] sys_read+0x53/0x90
 [<ffffffff80209a2e>] system_call+0x7e/0x83


--=-y2OdacEKQps3+qNjkHEN
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--=-y2OdacEKQps3+qNjkHEN
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-y2OdacEKQps3+qNjkHEN--
