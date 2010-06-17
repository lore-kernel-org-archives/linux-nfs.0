From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Syslog flooded: "NFSD: preprocess_seqid_op: magic stateid!"
Date: Wed, 16 Jun 2010 22:31:07 -0400
Message-ID: <20100617023106.GA20645@fieldses.org>
References: <501A322854D4C944BCAF0528CFC7B65E3B30E7F5EE@BALZ00SW-MBX.ads.mwn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Joschi Brauchle <joschi.brauchle@tum.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44794 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755843Ab0FQCbI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jun 2010 22:31:08 -0400
In-Reply-To: <501A322854D4C944BCAF0528CFC7B65E3B30E7F5EE-7sgYbYbIMHsZ3TY+6YjGZ+/kjxG1y2if@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 16, 2010 at 10:20:15AM +0200, Joschi Brauchle wrote:
> Hi everyone!
> I=E2=80=99m brand-new on the list and I hope this is the right place =
to post my questions.
> Please bear with me if there is some information missing,=E2=80=A6
>=20
> I am facing the following (first) problem on our primary NFSv4 filese=
rver (called pollux) running SLES 10SP3=20
> (Linux pollux 2.6.16.60-0.62.1-smp #1 SMP Mon Apr 12 18:53:46 UTC 201=
0 x86_64 x86_64 x86_64 GNU/Linux),=20
> the syslog is flooded with the following message:
>=20
> Jun=C2=A0 3 15:29:24 pollux kernel: NFSD: preprocess_seqid_op: magic =
stateid!

This was fixed by the commit below.

--b.

commit 2fdada03b3876ab9f84ede160f187e888cafefb4
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Fri Jul 27 16:10:37 2007 -0400

    knfsd: demote some printk()s to dprintk()s
   =20
    To quote a recent mail from Andrew Morton:
   =20
    	Look: if there's a way in which an unprivileged user can trigger
    	a printk we fix it, end of story.
   =20
    OK.  I assume that goes double for printk()s that might be triggere=
d by
    random hosts on the internet.  So, disable some printk()s that look=
 like
    they could be triggered by malfunctioning or malicious clients.  Fo=
r
    now, just downgrade them to dprintk()s.
   =20
    Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
    Acked-by:  Neil Brown <neilb@suse.de>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 29b7e63..18ead17 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -238,12 +238,12 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_c=
ompound_state *cstate,
 			break;
              	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
 			open->op_stateowner->so_confirmed =3D 1;
-			printk("NFSD: unsupported OPEN claim type %d\n",
+			dprintk("NFSD: unsupported OPEN claim type %d\n",
 				open->op_claim_type);
 			status =3D nfserr_notsupp;
 			goto out;
 		default:
-			printk("NFSD: Invalid OPEN claim type %d\n",
+			dprintk("NFSD: Invalid OPEN claim type %d\n",
 				open->op_claim_type);
 			status =3D nfserr_inval;
 			goto out;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 578d809..2b20eb8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -509,7 +509,7 @@ check_name(struct xdr_netobj name) {
 	if (name.len =3D=3D 0)=20
 		return 0;
 	if (name.len > NFS4_OPAQUE_LIMIT) {
-		printk("NFSD: check_name: name too long(%d)!\n", name.len);
+		dprintk("NFSD: check_name: name too long(%d)!\n", name.len);
 		return 0;
 	}
 	return 1;
@@ -1742,7 +1742,7 @@ out:
 	if (open->op_claim_type =3D=3D NFS4_OPEN_CLAIM_PREVIOUS
 			&& flag =3D=3D NFS4_OPEN_DELEGATE_NONE
 			&& open->op_delegate_type !=3D NFS4_OPEN_DELEGATE_NONE)
-		printk("NFSD: WARNING: refusing delegation reclaim\n");
+		dprintk("NFSD: WARNING: refusing delegation reclaim\n");
 	open->op_delegate_type =3D flag;
 }
=20
@@ -2151,7 +2151,7 @@ nfs4_preprocess_seqid_op(struct svc_fh *current_f=
h, u32 seqid, stateid_t *statei
 	*sopp =3D NULL;
=20
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid)) {
-		printk("NFSD: preprocess_seqid_op: magic stateid!\n");
+		dprintk("NFSD: preprocess_seqid_op: magic stateid!\n");
 		return nfserr_bad_stateid;
 	}
=20
@@ -2202,7 +2202,7 @@ nfs4_preprocess_seqid_op(struct svc_fh *current_f=
h, u32 seqid, stateid_t *statei
 	}
=20
 	if ((flags & CHECK_FH) && nfs4_check_fh(current_fh, stp)) {
-		printk("NFSD: preprocess_seqid_op: fh-stateid mismatch!\n");
+		dprintk("NFSD: preprocess_seqid_op: fh-stateid mismatch!\n");
 		return nfserr_bad_stateid;
 	}
=20
@@ -2218,22 +2218,22 @@ nfs4_preprocess_seqid_op(struct svc_fh *current=
_fh, u32 seqid, stateid_t *statei
 		goto check_replay;
=20
 	if (sop->so_confirmed && flags & CONFIRM) {
-		printk("NFSD: preprocess_seqid_op: expected"
+		dprintk("NFSD: preprocess_seqid_op: expected"
 				" unconfirmed stateowner!\n");
 		return nfserr_bad_stateid;
 	}
 	if (!sop->so_confirmed && !(flags & CONFIRM)) {
-		printk("NFSD: preprocess_seqid_op: stateowner not"
+		dprintk("NFSD: preprocess_seqid_op: stateowner not"
 				" confirmed yet!\n");
 		return nfserr_bad_stateid;
 	}
 	if (stateid->si_generation > stp->st_stateid.si_generation) {
-		printk("NFSD: preprocess_seqid_op: future stateid?!\n");
+		dprintk("NFSD: preprocess_seqid_op: future stateid?!\n");
 		return nfserr_bad_stateid;
 	}
=20
 	if (stateid->si_generation < stp->st_stateid.si_generation) {
-		printk("NFSD: preprocess_seqid_op: old stateid!\n");
+		dprintk("NFSD: preprocess_seqid_op: old stateid!\n");
 		return nfserr_old_stateid;
 	}
 	renew_client(sop->so_client);
@@ -2245,7 +2245,7 @@ check_replay:
 		/* indicate replay to calling function */
 		return nfserr_replay_me;
 	}
-	printk("NFSD: preprocess_seqid_op: bad seqid (expected %d, got %d)\n"=
,
+	dprintk("NFSD: preprocess_seqid_op: bad seqid (expected %d, got %d)\n=
",
 			sop->so_seqid, seqid);
 	*sopp =3D NULL;
 	return nfserr_bad_seqid;
@@ -2858,7 +2858,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_=
compound_state *cstate,
 			file_lock.fl_type =3D F_WRLCK;
 		break;
 		default:
-			printk("NFSD: nfs4_lockt: bad lock type!\n");
+			dprintk("NFSD: nfs4_lockt: bad lock type!\n");
 			status =3D nfserr_inval;
 		goto out;
 	}
