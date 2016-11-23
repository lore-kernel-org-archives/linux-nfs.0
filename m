Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56768 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752232AbcKWX0l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Nov 2016 18:26:41 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 24 Nov 2016 10:26:16 +1100
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
Subject: Re: [PATCH 2/2] mount: RPC_PROGNOTREGISTERED should not be a permanent error
In-Reply-To: <34768ca3-0aa1-eb00-01c9-922e3bbcb51f@RedHat.com>
References: <147157095612.26568.14161646901346011334.stgit@noble> <147157115640.26568.2934329194247787636.stgit@noble> <2a0955df-2fcd-05f1-9e6f-d8a549321177@RedHat.com> <87bmx7cezt.fsf@notabene.neil.brown.name> <34768ca3-0aa1-eb00-01c9-922e3bbcb51f@RedHat.com>
Message-ID: <87poll93s7.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 24 2016, Steve Dickson wrote:

> On 11/22/2016 05:43 PM, NeilBrown wrote:
>> On Wed, Nov 23 2016, Steve Dickson wrote:
>>=20
>>> [Resent due to mailman rejecting the HTML subpart]
>> (and the resend included HTML too ... how embarrassing :-)
> Yeah... :-) I guess an upgrade turned it on..=20
>
>>=20
>>>
>>> Hey Neil,
>>>
>>>
>>> On 08/18/2016 09:45 PM, NeilBrown wrote:
>>>> Commit: bf66c9facb8e ("mounts.nfs: v2 and v3 background mounts should =
retry when server is down.")
>>>>
>>>> changed the behaviour of "bg" mounts so that RPC_PROGNOTREGISTERED,
>>>> which maps to EOPNOTSUPP, is not a permanent error.
>>>> This useful because when an NFS server starts up there is a small wind=
ow between
>>>> the moment that rpcbind (or portmap) starts responding to lookup reque=
sts,
>>>> and the moment when nfsd registers with rpcbind.  During that window
>>>> rpcbind will reply with RPC_PROGNOTREGISTERED, but mount should not gi=
ve up.
>>>>
>>>> This same reasoning applies to foreground mounts.  They don't wait for
>>>> as long, but could still hit the window and fail prematurely.
>>>>
>>>> So revert the above patch and instead add EOPNOTSUPP to the list of
>>>> temporary errors known to nfs_is_permanent_error.
>>>>
>>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>>> ---
>>>>  utils/mount/stropts.c |    7 +++----
>>>>  1 file changed, 3 insertions(+), 4 deletions(-)
>>>>
>>>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>>>> index 9de6794c6177..d5dfb5e4a669 100644
>>>> --- a/utils/mount/stropts.c
>>>> +++ b/utils/mount/stropts.c
>>>> @@ -948,6 +948,7 @@ static int nfs_is_permanent_error(int error)
>>>>  	case ETIMEDOUT:
>>>>  	case ECONNREFUSED:
>>>>  	case EHOSTUNREACH:
>>>> +	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
>>> I think this introduced a regression... When the server does not support
>>> a protocol, say UDP, this patch cause the mount to hang forever,
>>> which I don't think we want.
>>=20
>>=20
>> I think we do want it to wait a while so that the nfs server has a
>> chance to start up.  We have no guarantee that the NFS server will be
>> registered with rpcbind before rpcbind responds to requests.
> I do see this race but there it has to be a small window. With
> Fedora its under seconds between the time rpcbind started
> and the NFS server.
>
>>=20
>> I disagree with the "hang forever" description.  I just tested after
>> disabling UDP on an nfs server, and the delay was 2 minutes, 5 seconds
>> before a failure was reported.  It might be longer when trying TCP on a
>> server that only supports UDP.
> Yeah I did not wait that long... You are much more of a patient man than =
I ;-)=20
> I do think this is a regression. Going an from an instant failure to one
> that takes over 2min is not a good thing... IMHO.
>
>>=20
>> So I think the current behavior is correct.  You might be able to argue
>> that certain error codes should trigger a shorter timeout, but it would
>> need a strong argument.
> Going with the theory the window is very small, how about=20
> a retry with a timeout then a failure?=20

I started looking at changing the timeout and it wouldn't be too hard
(if we can agree on a suitable delay), but I feel I must ask why this is
important.
In what situation are you likely to mount with the wrong protocol, that
you aren't able to just Ctrl-C when you realized what a dumb thing you
just did?

If rpcbind isn't running, which is arguably a very similar situation
(no protocols are register) we have always had a long timeout. Why is
"just one protocol not registered" any different?


Anyway, below is the patch I was working on.  I stopped when I wasn't
sure how to handle ECONNREFUSED.

NeilBrown



diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index d5dfb5e4a669..084776115b9f 100644
=2D-- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -935,24 +935,30 @@ static int nfs_try_mount(struct nfsmount_info *mi)
  * failed so far, but fail immediately if there is a local
  * error (like a bad mount option).
  *
=2D * ESTALE is also a temporary error because some servers
=2D * return ESTALE when a share is temporarily offline.
+ * If there is a remote error, like ESTALE or RPC_PROGNOTREGISTERED
+ * then it is probably permanent, but there is a small chance
+ * the it is temporary can we caught the server at an awkward
+ * time during start-up.  A shorter timeout is best for such
+ * circumstances, so return a distinct status.
  *
=2D * Returns 1 if we should fail immediately, or 0 if we
=2D * should retry.
+ * Returns PERMANENT if we should fail immediately,
+ * TEMPORARY if we should retry normally, or
+ * REMOTE if we should retry with shorter timeout.
  */
=2Dstatic int nfs_is_permanent_error(int error)
+enum error_type { PERMANENT, TEMPORARY, REMOTE };
+static enum error_type nfs_error_type(int error)
 {
 	switch (error) {
 	case ESTALE:
+	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
+		return REMOTE;
 	case ETIMEDOUT:
 	case ECONNREFUSED:
 	case EHOSTUNREACH:
=2D	case EOPNOTSUPP:	/* aka RPC_PROGNOTREGISTERED */
 	case EAGAIN:
=2D		return 0;	/* temporary */
+		return TEMPORARY;
 	default:
=2D		return 1;	/* permanent */
+		return PERMANENT;
 	}
 }
=20
@@ -967,6 +973,7 @@ static int nfsmount_fg(struct nfsmount_info *mi)
 {
 	unsigned int secs =3D 1;
 	time_t timeout;
+	int last_errno =3D 0;
=20
 	timeout =3D nfs_parse_retry_option(mi->options,
 					 NFS_DEF_FG_TIMEOUT_MINUTES);
@@ -987,13 +994,22 @@ static int nfsmount_fg(struct nfsmount_info *mi)
 			 */
 			return EX_SUCCESS;
=20
=2D		if (nfs_is_permanent_error(errno))
+		switch(nfs_error_type(errno)) {
+		case PERMANENT:
+			timeout =3D 0;
 			break;
=2D
=2D		if (time(NULL) > timeout) {
+		case REMOTE:
+			if (errno =3D=3D last_errno)
+				timeout =3D 0;
+			break;
+		case TEMPORARY:
 			errno =3D ETIMEDOUT;
 			break;
 		}
+		last_errno =3D errno;
+
+		if (time(NULL) > timeout)
+			break;
=20
 		if (errno !=3D ETIMEDOUT) {
 			if (sleep(secs))
@@ -1020,7 +1036,7 @@ static int nfsmount_parent(struct nfsmount_info *mi)
 	if (nfs_try_mount(mi))
 		return EX_SUCCESS;
=20
=2D	if (nfs_is_permanent_error(errno)) {
+	if (nfs_error_type(errno) =3D=3D PERMANENT) {
 		mount_error(mi->spec, mi->node, errno);
 		return EX_FAIL;
 	}
@@ -1055,8 +1071,14 @@ static int nfsmount_child(struct nfsmount_info *mi)
 		if (nfs_try_mount(mi))
 			return EX_SUCCESS;
=20
=2D		if (nfs_is_permanent_error(errno))
+		switch (nfs_error_type(errno)) {
+		case REMOTE: /* Doesn't hurt to keep trying remote errors
+			      * when in the background
+			      */
+		case PERMANENT:
+			timeout =3D 0;
 			break;
+		}
=20
 		if (time(NULL) > timeout)
 			break;

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYNiWYAAoJEDnsnt1WYoG5zRsP/ioQBTQNP8ov32c0hKG6Gpsg
smWkygcTi9WJXjWodMwq1gansBMn8uZ5MEyJHw9h1+36fpUCNc9b5Ns9R89WuX9N
COjSxDYPKHclq5traHIsekZduL36JQOyrslxb9LKbkkDc5Q2J4F2xFzC4W8KxIKv
fkZG/mkMOel7gx0Qa7z2ERoJHArIE1uT2CRtTDlTf/30vfZ0wpXESOBGKIja3d3g
mvuQknAJ7/0+Dq8tJrDqeruNM7qY2+l69CcYjBv1JfxuRbPr5QcWt5UE72xZPEUn
xW3hme3iLOkDRdkohVXx9uXMLtdo/zUOFgIIaLEiIL1TYY8fhI3bbD1suHakXkb8
qxAaV3udbVr8j+lCQR1FCeR8a4cqqGeai9sLAU7VSnMPZDS+99IMarE605jB2MSQ
osHdrpgeeNi9jRDEhrf8BAX2amV4nNDSCxnWta5rr6MBJTlyiQ5f8zG13m0nZNna
0RDIQU7GF6f6IvJcflY+87lPXzTTiRjAZAuKlmyYtndPNq6z1M3d5/7PtJdiv++1
cMCy9rqQVjA0S/R4oYB+45C6Im1F7ICjMubBuSFNITLhquUWSUaPN/arSOKrQ161
gR26jF+4vuYAU+15Qc4iHUZn7zEmpCH5YG3+9thsgv48Y38kU4swWW5uLU5truaB
oBsSqQ6AMsR+m59GlwDd
=WvLw
-----END PGP SIGNATURE-----
--=-=-=--
