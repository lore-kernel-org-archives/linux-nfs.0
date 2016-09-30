Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34869 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750776AbcI3CQ5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Sep 2016 22:16:57 -0400
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>
Date: Fri, 30 Sep 2016 12:16:48 +1000
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: wrong stateid used after flock lock taken
Message-ID: <87twcy5dyn.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


Hi Jeff et al.

I think your patch
Commit: 8003d3c4aaa5 ("nfs4: treat lock owners as opaque values")

introduced a regression ... or maybe exposed a latent problem.

The particular symptom that I can demonstrate is that if I open a file
with NFSv4, take a flock() exclusive lock, and then write to the file,
then the WRITE request uses the stateid returned by OPEN, not the one
returned by LOCK.

The Linux NFS server doesn't have a problem with that, but some NFS
servers do (one returns NFS4ERR_LOCKED, which seems to imply it imposes
mandatory locking!).
In any case, this is the wrong stateid to use.

The patch changed nfs4_copy_lock_stateid() so it was more restrictive in
the stateids it allowed.
I must admit that I find the code that you removed incredibly confusing.
I defined a union field
-               pid_t flock_owner;

and I cannot understand how a pid_t would be relevant for a flock_owner,
as the flock is tied to the 'struct file', not the pid.

Anyway, a write request includes an 'nfs_lock_context' and from that we
need to somehow find the correct stateid.
I'm wondering if nfs4_set_rw_stateid() should call
nfs4_select_rw_stateid() twice, once to look for a flock stated, and
once to look for a posix-lock stateid .... or something like that.

I'll take a fresh look at the code next week and maybe it will be easier
to understand then, but meanwhile if you have any suggestions I'd be
very happy to hear them.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJX7csRAAoJEDnsnt1WYoG5KMcQAKoZ6AG9H8OkXBbwo1X5khS4
HI9Jrd8v+bi9SWs1rEh1HFxJe2jeKHrrNzNrLQijzAEMQoYN4iBHxPoHRCHmlm9A
1aP9whNde2NCWiNjMX2XDQFJueGEAfIYsoQfRy+dVk2MvoQMQe82N+k2TXmoswu7
05DYWoyytz1tEDTQ5xwz/eDo4DCZkhgaiXppfHtUbQjFNaqvD9uoR1SUyI26cxEo
Q2OSuw4dpw+2l1OECw1TkCleCSkYiRrNMdr/Ladt9tMKPJ9EEw+P0sDjGHkpV67K
h+cjI6etIjaDxy5OVIAKbZHCFA3TPQKz+WTz+7BlA7wE6EdFysJ4V3tKj+zClCjh
xxbn0KFY1IkuGt+bboA/fPRzg+7c7RGyVnVT5pIk5Fore4Xw/sQRpGVbAIxDMsM5
K0oWNvuAoQTedowy/kuvOQT/sB4eklgtuzzQmp9Y25VeexX0pjrED3+fwZueNmVo
O74ZSQpVhYI7Nt8kNbpQPal62ZBb95cIAoiCbFJESVLuz7lJWr8D9LKvjIFVQc7A
YkdBjFjri9nUguCRRY/1JalfhPq5Rowk2ES/8XUluh1sUtPuTSqkiNIirbdXfNDn
I19pqFJsTe85mW9CWX+w0w2WEJuvNEUATXEyE2STgDw4otZtaiTQRMze6DLvgDkP
qYx1Ys5gKyrc/HOB2vGv
=qC7j
-----END PGP SIGNATURE-----
--=-=-=--
