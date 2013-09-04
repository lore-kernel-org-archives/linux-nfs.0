Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:28797 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934808Ab3IDPvc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Sep 2013 11:51:32 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: multipart/mixed; boundary="Apple-Mail=_AE8EC926-322C-41AD-A09F-726B4D336350"
Subject: Two compiler warning fix-ups
Date: Wed, 4 Sep 2013 11:51:28 -0400
Message-Id: <14DDA7D6-DB8E-4E2A-B45C-4A8CD75A077D@oracle.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_AE8EC926-322C-41AD-A09F-726B4D336350
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Sorry for the attachments.  "git mail" is not yet working from my test =
machine inside the Oracle firewall.

--
Chuck Lever
chuck.lever@oracle.com


--Apple-Mail=_AE8EC926-322C-41AD-A09F-726B4D336350
Content-Disposition: attachment;
	filename=nfs-fix-sparse-warning
Content-Type: application/octet-stream;
	name="nfs-fix-sparse-warning"
Content-Transfer-Encoding: 7bit

NFS: Fix sparse warning introduced by NFSv4.0 transport blocking patches

From: Chuck Lever <chuck.lever@oracle.com>

When CONFIG_NFS_V4_1 is not enabled, "make C=2" emits this warning:

linux/fs/nfs/nfs4session.c:337:6: warning:
 symbol 'nfs41_set_target_slotid' was not declared. Should it be static?


Move nfs41_set_target_slotid() and nfs41_update_target_slotid() back
behind CONFIG_NFS_V4_1, since, in the final revision of this work,
they are used only in NFSv4.1 and later.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4session.c |    4 ++--
 fs/nfs/nfs4session.h |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index e0bf666..cf883c7 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -310,6 +310,8 @@ void nfs41_wake_slot_table(struct nfs4_slot_table *tbl)
 	}
 }
 
+#if defined(CONFIG_NFS_V4_1)
+
 static void nfs41_set_max_slotid_locked(struct nfs4_slot_table *tbl,
 		u32 target_highest_slotid)
 {
@@ -420,8 +422,6 @@ void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
 	spin_unlock(&tbl->slot_tbl_lock);
 }
 
-#if defined(CONFIG_NFS_V4_1)
-
 static void nfs4_destroy_session_slot_tables(struct nfs4_session *session)
 {
 	nfs4_release_slot_table(&session->fc_slot_table);
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 92c27f4..a2f808c 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -78,9 +78,6 @@ extern void nfs4_release_slot_table(struct nfs4_slot_table *tbl);
 extern struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl);
 extern void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
 extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);
-extern void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
-		struct nfs4_slot *slot,
-		struct nfs4_sequence_res *res);
 bool nfs41_wake_and_assign_slot(struct nfs4_slot_table *tbl,
 		struct nfs4_slot *slot);
 void nfs41_wake_slot_table(struct nfs4_slot_table *tbl);
@@ -93,6 +90,9 @@ static inline bool nfs4_slot_tbl_draining(struct nfs4_slot_table *tbl)
 #if defined(CONFIG_NFS_V4_1)
 extern void nfs41_set_target_slotid(struct nfs4_slot_table *tbl,
 		u32 target_highest_slotid);
+extern void nfs41_update_target_slotid(struct nfs4_slot_table *tbl,
+		struct nfs4_slot *slot,
+		struct nfs4_sequence_res *res);
 
 extern int nfs4_setup_session_slot_tables(struct nfs4_session *ses);
 

--Apple-Mail=_AE8EC926-322C-41AD-A09F-726B4D336350
Content-Disposition: attachment;
	filename=nfs-fix-other-sparse-warning
Content-Type: application/octet-stream;
	name="nfs-fix-other-sparse-warning"
Content-Transfer-Encoding: quoted-printable

NFS:=20Fix=20warning=20introduced=20by=20NFSv4.0=20transport=20blocking=20=
patches=0A=0AFrom:=20Chuck=20Lever=20<chuck.lever@oracle.com>=0A=0AWhen=20=
CONFIG_NFS_V4_1=20is=20not=20enabled,=20gcc=20emits=20this=20warning:=0A=0A=
linux/fs/nfs/nfs4state.c:255:12:=20warning:=0A=20=
=E2=80=98nfs4_begin_drain_session=E2=80=99=20defined=20but=20not=20used=20=
[-Wunused-function]=0A=20static=20int=20nfs4_begin_drain_session(struct=20=
nfs_client=20*clp)=0A=20=20=20=20=20=20=20=20=20=20=20=20^=0A=0A=
Eventually=20NFSv4.0=20migration=20recovery=20will=20invoke=20this=20=
function,=20but=0Athat=20has=20not=20yet=20been=20merged.=20=20Hide=20=
nfs4_begin_drain_session()=0Abehind=20CONFIG_NFS_V4_1=20for=20now.=0A=0A=
Signed-off-by:=20Chuck=20Lever=20<chuck.lever@oracle.com>=0A---=0A=20=
fs/nfs/nfs4state.c=20|=20=20=20=204=20++--=0A=201=20file=20changed,=202=20=
insertions(+),=202=20deletions(-)=0A=0Adiff=20--git=20=
a/fs/nfs/nfs4state.c=20b/fs/nfs/nfs4state.c=0Aindex=20d816d93..4921dc3=20=
100644=0A---=20a/fs/nfs/nfs4state.c=0A+++=20b/fs/nfs/nfs4state.c=0A@@=20=
-239,6=20+239,8=20@@=20static=20void=20nfs4_end_drain_session(struct=20=
nfs_client=20*clp)=0A=20=09}=0A=20}=0A=20=0A+#if=20=
defined(CONFIG_NFS_V4_1)=0A+=0A=20static=20int=20=
nfs4_drain_slot_tbl(struct=20nfs4_slot_table=20*tbl)=0A=20{=0A=20=09=
set_bit(NFS4_SLOT_TBL_DRAINING,=20&tbl->slot_tbl_state);=0A@@=20-268,8=20=
+270,6=20@@=20static=20int=20nfs4_begin_drain_session(struct=20=
nfs_client=20*clp)=0A=20=09return=20=
nfs4_drain_slot_tbl(&ses->fc_slot_table);=0A=20}=0A=20=0A-#if=20=
defined(CONFIG_NFS_V4_1)=0A-=0A=20static=20int=20=
nfs41_setup_state_renewal(struct=20nfs_client=20*clp)=0A=20{=0A=20=09int=20=
status;=0A=

--Apple-Mail=_AE8EC926-322C-41AD-A09F-726B4D336350--
