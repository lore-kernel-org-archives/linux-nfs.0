Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37604 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934191AbeCTAcm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Mar 2018 20:32:42 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "tigran.mkrtchyan\@desy.de" <tigran.mkrtchyan@desy.de>
Date: Tue, 20 Mar 2018 11:32:33 +1100
Cc: "anna.schumaker\@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - v2] NFSv4: handle EINVAL from EXCHANGE_ID better.
In-Reply-To: <1521202233.3008.16.camel@primarydata.com>
References: <87bmfoc3yi.fsf@notabene.neil.brown.name> <878tasc3ag.fsf@notabene.neil.brown.name> <584484878.12780264.1521192712528.JavaMail.zimbra@desy.de> <1521202233.3008.16.camel@primarydata.com>
Message-ID: <87o9jja8ny.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 16 2018, Trond Myklebust wrote:

> On Fri, 2018-03-16 at 10:31 +0100, Mkrtchyan, Tigran wrote:
>> Hi Neil,
>>=20
>> according to rfc5661, NFS4ERR_INVAL is returned by the server if it
>> thinks that client sends an invalid request (e.g. points to a client
>> bug)
>> or server misinterpret it (broken server).
>>=20
>> With your change instead of failing the mount, client will silently
>> go for
>> v4.0, even v4.1 mount was requested and produce undesirable behavior,
>> e.g.
>> proxy-io instead of pnfs. I fill prefer fail-fast instead of long
>> debug
>> sessions.
>>=20
>> On the other hand, I understand, that it's not always possible to fix
>> server
>> or clients in production environment and time-to-time workarounds are
>> necessary.
>>=20
>>=20
>
> I'd tend to agree with Tigran. Hiding server bugs, should not be a
> priority and particularly not in this case, where the workaround is
> simple: either turn off version negotiation altogether, or edit
> /etc/nfsmount.conf to negotiate a different set of versions.

Yes, it could be worked-around in nfsmount.conf, but manual
configuration should be seen as an optimization or a last resort.   If
we can make things work without configuration, that provides the best
experience.
In this case, the kernel has strong evidence that the server
isn't responding as expected, but it gives an unhelpful error message.

At the very least, nfs4_discover_server_trunking() should not treat
=2DNFS4ERR_INVAL as unexpect (because there is code in
nfs4_check_cl_exchange_flags which explicitly generates it).
If it just let this error through, instead of translating it to EIO,
then the problem would go away.

>
> What we might want to do, is make it easier to allow the user to detect
> that this is indeed a server bug and is not a problem with the
> arguments supplied to the "mount" utility. Perhaps we might have the
> kernel log something in the syslogs?

Yes, logging a message might be useful.  Most of the messages logged
about bad servers are currently going through dprintk(), so they won't
often be seen.  Is that what we want??  Don't know...

Anyway, you point that it "is not a problem with the arguments" is
stop-on.  If the client gets EINVAL from the server, then it shouldn't
blindly report that back to the user as EINVAL means "Invalid
argument" and the argements given to the server are probably not the
argument given by the user.

Following that line of reasoning, I think nfs4_check_cl_exchange_flag()
should *not* return -NFS4ERR_INVAL, and _nfs4_proc_exchange_id()
shouldn't pass NFS4ERR_INVAL through unchanged.

So I propose the following version.

Thanks,
NeilBrown

=2D-----------------------8<---------------------------
From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Mar 2018 11:31:33 +1100
Subject: [PATCH] NFSv4: handle EINVAL from EXCHANGE_ID better.

nfs4_proc_exchange_id() can return -EINVAL if the server
reported NFS4INVAL (which I have seen in a packet trace),
or nfs4_check_cl_exchange_flags() exchange flags detects
a problem.
Each of these mean that NFSv4.1 and later cannot be used,
but they should not prevent fallback to NFSv4.0.  Currently
they do.

Currently this EINVAL error is returned by
nfs4_proc_exchange_id() to nfs41_discover_server_trunking(),
and thence to nfs4_discover_server_trunking().
nfs4_discover_server_trunking() doesn't understand EINVAL,
so converts it to EIO which causes mount.nfs to think
something is horribly wrong and to give up.

EINVAL is never a sensible error code here.  It means "Invalid
argument", but is being used when the problem is "Invalid response
from the server".  If we change these two circumstances to report
EPROTONOSUPPORT to the caller (which seems a reasonable assessment
when the server gives confusing responses), and if we enhance
nfs4_discover_server_trunking() to treat -EPROTONOSUPPORT as an
expected error to pass through, then the error reported to user-space
will be more representative of the actual fault.

A failure to negotiate a client ID clearly shows that NFSv4.1 cannot
be supported, but isn't as general a failure as EIO.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/nfs4proc.c  | 18 +++++++++++++++---
 fs/nfs/nfs4state.c |  1 +
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 47f3c273245e..97757f646f13 100644
=2D-- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7364,7 +7364,8 @@ static int nfs4_check_cl_exchange_flags(u32 flags)
 		goto out_inval;
 	return NFS_OK;
 out_inval:
=2D	return -NFS4ERR_INVAL;
+	dprintk("NFS: server returns invalid flags for EXCHANGE_ID\n");
+	return -EPROTONOSUPPORT;
 }
=20
 static bool
@@ -7741,8 +7742,19 @@ static int _nfs4_proc_exchange_id(struct nfs_client =
*clp, struct rpc_cred *cred,
 	int status;
=20
 	task =3D nfs4_run_exchange_id(clp, cred, sp4_how, NULL);
=2D	if (IS_ERR(task))
=2D		return PTR_ERR(task);
+	if (IS_ERR(task)) {
+		status =3D PTR_ERR(task);
+		if (status =3D=3D -NFS4ERR_INVAL) {
+			/* If the server think we did something invalid, it is certainly
+			 * not the fault of our caller, so it would wrong to report
+			 * this error back up.  So in that case simply acknowledge that
+			 * we don't seem able to support this protocol.
+			 */
+			dprintk("NFS: server return NFS4ERR_INVAL to EXCHANGE_ID\n");
+			status =3D -EPROTONOSUPPORT;
+		}
+		return status;
+	}
=20
 	argp =3D task->tk_msg.rpc_argp;
 	resp =3D task->tk_msg.rpc_resp;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 91a4d4eeb235..273c032089c4 100644
=2D-- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2219,6 +2219,7 @@ int nfs4_discover_server_trunking(struct nfs_client *=
clp,
 		clnt =3D clp->cl_rpcclient;
 		goto again;
=20
+	case -EPROTONOSUPPORT:
 	case -NFS4ERR_MINOR_VERS_MISMATCH:
 		status =3D -EPROTONOSUPPORT;
 		break;
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlqwVqEACgkQOeye3VZi
gbnhXBAAk0jf1jgPjfzoMCdEYgsl/lwIMW0XuBnD2nuPmIKo1b1li6+fk3087lu/
AYzxocqZp23guutJjfZmSV4b0MOxRsk7MOtJjvLaISdor4c/lxla8pRVu9VbKUmb
ac49iU9/47TtyetAk+tQi9/Jpsz00r/L4REDyZ47ZLKyXe/5izxbxwMztNVmGv/F
YDGanXOXJFrSaI2DyI2ICSNTE0WFm1mVQ+tcx2Ul1EtJrT2FO0y9g2av1uvlJxg4
dDt24FFoODGcvFC4TgVVgTId4NAss3mBIxli9saUhrc4OjZs5IiKTY234vvMU/jv
azhu4hpTTS+tj0dkqNnPEgw6X51o+Ruz5vjvQD58zWgJiqCeDjhQDXsXAUswyg5W
jFUFeL0c5EnzH5G7YWWkYOaPcpxk5RynlONT1RxjUCYFe6PYPbqjN2AJDJL4w4vB
mkESI9JnPnnK4X1SfmiDvLWl61E6l8LgisJKIJ8eTq1V9fX90cCBalkDyTX4xA6y
WBzF4WmzIPy7KmPkriDH5G2qjJ67Jvja58/FonHES64CFvHSs4V5R/u4rQbMZId6
fX7HlkDmcWADZ9yu8e+MmvKiytCfoXEAesm77lXBJKAf6VfHrTUc7AfziduECe++
PrwIY0rN+7+OAz/z71s7Y7to4lV+TCb3lnAxfQ3Gy0S2P2Dftck=
=Bm42
-----END PGP SIGNATURE-----
--=-=-=--
