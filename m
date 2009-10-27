From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [RFC][PATCH 0/3] nlm:Fix bug nlm cann't process retransmited request
 correctly
Date: Tue, 27 Oct 2009 11:22:41 +0800
Message-ID: <4AE66781.1020608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, bfields@fieldses.org,
	mingo@elte.hu
To: "Trond.Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57850 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753343AbZJ0DVs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Oct 2009 23:21:48 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 I found a bug when tested NLM. The case likes followed:

           client                          server
             |                                |
      step1  |           open file            |
      open   |------------------------------->|
             |              ok                |
             |<-------------------------------|
             |                                | step2
             |                             -> | <-  service nfslock sto=
p
             |                                |
             | WL1: write lock request{0, 0}  |
      step3  |------------------------------->|
      fcntl  |                                |=20
             |                                |
             |    WL1_re: WL1 retransmit      |
             |------------------------------->|
             |                                |
             |       WL1.reply   ENOLCK       |
             |<-------------------------------|
             |                                |
             |                                | step4
             |                             -> | <- service nfslock star=
t
             |                                |
             | WL2: write lock request{0, 0}  |
      step5  |------------------------------->|
      fcntl  |                                |
             |        WL1_re.reply OK         |
             |<-------------------------------|
             |       WL2.reply EBLOCKD        |
             |<-------------------------------|


   client can not acquire for write lock any more after step4.

 Reason:
     Server reply ENOLCK for WL1 to client because nfslock service stop=
ed, but it can not
   distinguish  retransmited request with normal request, so it reply O=
K for WL1_re to
   client after nfslock service start. But fcntl client called will ret=
urn when it receive
   WL1.reply, and WL2 can not get a equal svid to WL1_re=EF=BC=8Cso ser=
ver will reply EBLOCKD for
   it.

 Suggestion:

   I suggest add an DRC for NLM.
   There are three patchs followed:

   1. add an universal DRC to sunrpc, it will be used by those protocol
      which be built on sunrpc
      [0001-Add-an-universal-DRC-to-sunrpc.patch]

   2. add DRC to NLM using sunrpc's universal DRC
      [0002-Add-DRC-to-NLM-using-sunrpc-s-DRC.patch]

   3. modify the nfsd's DRC to use sunrpc's universal DRC
      [0003-Modify-the-nfsd-s-DRC-to-use-sunrpc-s-universal-DRC.patch]

--

 arch/parisc/kernel/sys_parisc32.c |    2 +-
 arch/s390/kernel/compat_linux.c   |    2 +-
 arch/sparc/kernel/sys_sparc32.c   |    2 +-
 fs/lockd/svc.c                    |   66 ++++++++
 fs/lockd/svc4proc.c               |   52 +++---
 fs/nfsd/Makefile                  |    2 +-
 fs/nfsd/nfs2acl.c                 |    2 +-
 fs/nfsd/nfs3acl.c                 |    2 +-
 fs/nfsd/nfs3proc.c                |    2 +-
 fs/nfsd/nfs4proc.c                |    2 +-
 fs/nfsd/nfs4state.c               |    2 +-
 fs/nfsd/nfscache.c                |  330 -----------------------------=
--------
 fs/nfsd/nfsctl.c                  |   10 +-
 fs/nfsd/nfsproc.c                 |    2 +-
 fs/nfsd/nfssvc.c                  |   13 +-
 fs/nfsd/stats.c                   |    9 +-
 include/linux/lockd/lockd.h       |    6 +
 include/linux/nfsd/cache.h        |   62 -------
 include/linux/nfsd/stats.h        |    3 -
 include/linux/sunrpc/drc.h        |   97 +++++++++++
 net/sunrpc/Makefile               |    2 +-
 net/sunrpc/drc.c                  |  326 +++++++++++++++++++++++++++++=
+++++++
 22 files changed, 553 insertions(+), 443 deletions(-) =20

--=20
Regards
Mi Jinlong

