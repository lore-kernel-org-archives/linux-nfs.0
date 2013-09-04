Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35046 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761528Ab3IDBgp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Sep 2013 21:36:45 -0400
Date: Wed, 4 Sep 2013 11:36:32 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH/RFC] make nfs_flush_incompatible more forgiving.
Message-ID: <20130904113632.1a1eb337@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/dwbkUAqr0yhzNpFy=UGyzkF"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/dwbkUAqr0yhzNpFy=UGyzkF
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi,
 we have a customer who has noticed a significant regression in NFS
 performance between SLES10 (2.6.16+) and SLES11 (3.0+).

 The use case involves two different processes on the same client mmapping a
 file and making changes.

 In 2.6.16, all these changes would be cached on the client until a flush or
 close or other normal process flushed the changes out - much the same as if
 just one process was accessing the file.

 In 3.0 the file is flushed out every time a different process performs an
 update. So if they interleave accesses, you get a flush-to-the-server on
 every access.

 This is caused by nfs_flush_incompatible.  It deems access through differe=
nt
 file descriptors to be incompatible.  However I don't think this is
 justified.  Accessed using different credentials can reasonably be seen as
 incompatible(*), but if two processes with identical credentials open the
 same file there there should be not need to differentiate between them.

 The patch below changes the test in nfs_flush_incompatible to just test the
 credentials (and the dentry, though that might be superfluous - it seems
 safer).

(*) In this specific customer's case the process do currently have slightly
 different credentials.  In one, the primary gid is included in the list of
 auxiliary gids.  In the other the primary gid is excluded.  This is enough
 to make the credentials appear different so this patch doesn't help in that
 case.  They are looking at being more consistent in their setgroups usage
 but it would help them if we only actually compared the credentials that
 were important.  In this case there is no important difference.
 Would it make sense to treat a more broad credential as compatible with a
 more narrow credential?  So a write from a process with a given
 uid,gid,grouplist could ultimately be sent to the server with same uid/gid,
 but a subset of the group list?
=20

 Thoughts?

Thanks,
NeilBrown


diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7816801..b0d4e47 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -860,7 +860,12 @@ int nfs_flush_incompatible(struct file *file, struct p=
age *page)
 		if (req =3D=3D NULL)
 			return 0;
 		l_ctx =3D req->wb_lock_context;
-		do_flush =3D req->wb_page !=3D page || req->wb_context !=3D ctx;
+		do_flush =3D req->wb_page !=3D page;
+		if (req->wb_context !=3D ctx) {
+			do_flush |=3D
+				req->wb_context->dentry !=3D ctx->dentry ||
+				req->wb_context->cred !=3D ctx->cred;
+		}
 		if (l_ctx) {
 			do_flush |=3D l_ctx->lockowner.l_owner !=3D current->files
 				|| l_ctx->lockowner.l_pid !=3D current->tgid;

--Sig_/dwbkUAqr0yhzNpFy=UGyzkF
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUiaOoTnsnt1WYoG5AQK2TxAAhD0HKeCk1+O7y8fpyE1SPqLFLr1Rq5kc
338RUO9EoFdIt15v9gl4hMqQybDc6nxEy8rqWlUHUhQ0t+BiTNKlkJSSzF4rqxYL
hEIsFhE8CHmgN7/XkFlG0KuEwEdstLboZ271/EfAqCtvCAhOYp7ekWZKl27Pm46x
IF4asJzqEncw6F/4AXba4UZW4115TYzIyzF5cs4sSHURf9Sz9NWB6zPcNXeabKrB
8PHQi+m1uYk82J5bcHj+N5lr0+Q3HdXqGnpDjD+AabFZ7W5LUbv0OAEfXdd95PJp
8o7M2dboSrZ2w2vdMM3JMPEZ/bNnt+p+YNAor/EsVFknb3j0IlONvkmv58N11ew5
7S48q7eh2XxADghvbhnCBOZ4GK9fPqtkFBHUkkDRPYjNGS67V5PPTdRl7+Bnj56S
YSGiXWMWp8gpSj0MDC+wKvjrc6fTY2Pls96L1rm1tyETGYRBc6WK4u+675dFUEz6
XLMsaVf3sC9YTz9IDNbtZaUiQZYiiXT7smfGlSb6XR4u2Wppj51SIhho2EuiuRW7
WP2eyb9DR/3QXk9kDQfoLopqmiM9MVpWx7f6UMvgaofZKxMEGJQJ6w4xuplOY4Su
64QyFdSdiKK+BnCQSvjdmDvxr66Wyo3qu/Ofx3cliUYWQ27I1rm7Aoozx4MY9pxU
2n6ErZ69KGA=
=t8jS
-----END PGP SIGNATURE-----

--Sig_/dwbkUAqr0yhzNpFy=UGyzkF--
