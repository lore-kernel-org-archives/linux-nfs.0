From: Marc Dietrich <Marc.Dietrich@ap.physik.uni-giessen.de>
Subject: nfs4 client hangs in D state
Date: Tue, 30 May 2006 17:05:57 +0200
Message-ID: <200605301705.59293.marc.dietrich@ap.physik.uni-giessen.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fl5nf-0005KU-In
	for nfs@lists.sourceforge.net; Tue, 30 May 2006 08:06:27 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fl5nf-000311-BQ
	for nfs@lists.sourceforge.net; Tue, 30 May 2006 08:06:27 -0700
Received: from merkurneu.hrz.uni-giessen.de ([134.176.2.3])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fl5ne-0003lF-Ru
	for nfs@lists.sourceforge.net; Tue, 30 May 2006 08:06:27 -0700
Received: from [134.176.2.191] by merkurneu.hrz.uni-giessen.de with ESMTP for nfs@lists.sourceforge.net; Tue, 30 May 2006 17:06:03 +0200
Received: from hermes.hrz.uni-giessen.de (hermes.hrz.uni-giessen.de [134.176.2.15])
	by mailgw12.hrz.uni-giessen.de (Postfix) with ESMTP id 4D5082C8A4B
	for <nfs@lists.sourceforge.net>; Tue, 30 May 2006 17:05:58 +0200 (CEST)
Received: from fb07-iapwap2.physik.uni-giessen.de by hermes.hrz.uni-giessen.de with ESMTP for nfs@lists.sourceforge.net; Tue, 30 May 2006 17:06:00 +0200
To: nfs@lists.sourceforge.net
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


Hi,

one of my fresh installed SuSE 10.1 clients frequently hangs when copying d=
ata=20
from the (fresh installed SuSE 10.1) nfs4 server. I still can login as root=
,=20
but access to the mounted directories is impossible.=20
alt-sys-t gives that:

 c9a61f34 cf25ea60 0000000a cc68c16c cc68c030 9c939900 003dece3 00000000
        c5933a6c c013d1ba 15ef3c00 00000000 c9a61f74 00000001 cc68cab0=20
00000000
        c0119596 00000006 ffffffff cc68c030 00000001 cc68c0f0 00000001=20
00000000
 Call Trace:
  [<c013d1ba>] __handle_mm_fault+0x6ca/0x75b
  [<c0119596>] do_wait+0x813/0x8e3
  [<c0158df2>] do_ioctl+0x3a/0x49
  [<c01149a3>] default_wake_function+0x0/0xc
  [<c011968d>] sys_wait4+0x27/0x2a
  [<c01196a3>] sys_waitpid+0x13/0x17
  [<c01029db>] sysenter_past_esp+0x54/0x79
 cp            S CC68CBEC     0 15571  15535                     (NOTLB)
 c4f79cd4 c4f79cdc 00000008 cc68cbec cc68cab0 9cd0a200 003dece3 00000000
        00000000 00000000 003d0900 00000000 c4f79d24 00000000 c4f79d2c=20
c12003b0
        d0b3c7ee c027258d d0b3c7d1 c4f79d24 cf2f321c c4f79d20 00000000=20
c0272627
 Call Trace:
  [<d0b3c7ee>] nfs4_wait_bit_interruptible+0x1d/0x22 [nfs]
  [<c027258d>] __wait_on_bit+0x33/0x58
  [<d0b3c7d1>] nfs4_wait_bit_interruptible+0x0/0x22 [nfs]
  [<c0272627>] out_of_line_wait_on_bit+0x75/0x7d
  [<d0b3c7d1>] nfs4_wait_bit_interruptible+0x0/0x22 [nfs]
  [<c0125995>] wake_bit_function+0x0/0x3f
  [<d0b384aa>] nfs4_wait_clnt_recover+0x43/0x57 [nfs]
  [<d0b3c34d>] nfs4_open_revalidate+0xaf/0x395 [nfs]
  [<d0b2b5fe>] nfs_open_revalidate+0x80/0xfc [nfs]
  [<c015550b>] do_lookup+0x10a/0x135
  [<c0156e6f>] __link_path_walk+0x6c1/0xab6
  [<c01607b9>] mntput_no_expire+0x11/0x59
  [<c01572ab>] link_path_walk+0x47/0xb9
  [<c01575cc>] do_path_lookup+0x198/0x1e6
  [<c0157e6c>] __path_lookup_intent_open+0x42/0x72
  [<c0157eeb>] path_lookup_open+0xf/0x13
  [<c0157fae>] open_namei+0x62/0x4e4
  [<c01523bb>] vfs_stat_fd+0x15/0x3c
  [<c014987d>] do_filp_open+0x1d/0x32
  [<c01498d0>] do_sys_open+0x3e/0xb0
  [<c014996f>] sys_open+0x16/0x18
  [<c01029db>] sysenter_past_esp+0x54/0x79
 134.176.19.12 D CC68016C     0 15572      5                2500 (L-TLB)

Anything I can do to debug this further?
This seems to happen only on this single machine. All others (also SuSE 10.=
1)=20
are running well (up to now). Maybe a configure problem?

Greetings

	marc


=2D-=20
	"Das feindliche Lager tr=E4gt die alleinige Schuld am Krieg."
		 Lord Arthur Ponsonby, "Falsehood in Wartime: Propaganda Lies of the Firs=
t=20
World War", 1928


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
