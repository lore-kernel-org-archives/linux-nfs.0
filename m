Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42318 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011AbaCGH7p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2014 02:59:45 -0500
Date: Fri, 7 Mar 2014 18:59:37 +1100
From: NeilBrown <neilb@suse.de>
To: Jim Rees <rees@umich.edu>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] fix intr/nointr to match kernel behavior (ignored)
Message-ID: <20140307185937.5852666b@notabene.brown>
In-Reply-To: <1394143352-26095-1-git-send-email-rees@umich.edu>
References: <1394143352-26095-1-git-send-email-rees@umich.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/MFIHH3jtgzawt00O3OitVl_"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/MFIHH3jtgzawt00O3OitVl_
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu,  6 Mar 2014 17:02:32 -0500 Jim Rees <rees@umich.edu> wrote:

> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  utils/mount/nfs.man | 53 ++++++-----------------------------------------=
------
>  1 file changed, 6 insertions(+), 47 deletions(-)
>=20
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index ef09a31..2ab369c 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -125,6 +125,12 @@ option may mitigate some of the risks of using the
>  .B soft
>  option.
>  .TP 1.5i
> +.BR intr " / " nointr
> +This option is provided for backward compatibility.
> +It is ignored after kernel 2.6.25.
> +System calls return EINTR if an in-progress NFS operation is interrupted=
 by
> +a signal.

That isn't correct.
"A process that is waiting for a reply for an NFS server can be killed
 by any signal which would normally kill the process.  If a signal would not
 normally kill the process (i.e. it is caught or ignored) then that signal
 will not abort and NFS request".

This is really a fairly horrible semantic.  It makes perfect sense from an
internal implementation perspective and provides good backwards compatibili=
ty
and cross-compatibility with other filesystems (where 'read' and 'write'
never ever return EINTR), but it is very hard to document clearly.

NeilBrown


> +.TP 1.5i
>  .BI timeo=3D n
>  The time in deciseconds (tenths of a second) the NFS client waits for a
>  response before it retries an NFS request.
> @@ -668,30 +674,6 @@ Using the
>  option is also required when mounting exports on NFS servers
>  that do not support the NLM protocol.
>  .TP 1.5i
> -.BR intr " / " nointr
> -Selects whether to allow signals to interrupt file operations
> -on this mount point. If neither option
> -is specified (or if
> -.B nointr
> -is specified),
> -signals do not interrupt NFS file operations. If
> -.B intr
> -is specified, system calls return EINTR if an in-progress NFS operation =
is interrupted by
> -a signal.
> -.IP
> -Using the
> -.B intr
> -option is preferred to using the
> -.B soft
> -option because it is significantly less likely to result in data corrupt=
ion.
> -.IP
> -The
> -.BR intr " / " nointr
> -mount option is deprecated after kernel 2.6.25.
> -Only SIGKILL can interrupt a pending NFS operation on these kernels,
> -and if specified, this mount option is ignored to provide backwards
> -compatibility with older kernels.
> -.TP 1.5i
>  .BR cto " / " nocto
>  Selects whether to use close-to-open cache coherence semantics.
>  If neither option is specified (or if
> @@ -807,29 +789,6 @@ The mount request fails if the server's rpcbind serv=
ice is not available,
>  the server's NFS service is not registered with its rpcbind service,
>  or the server's NFS service is not available on the advertised port.
>  .TP 1.5i
> -.BR intr " / " nointr
> -Selects whether to allow signals to interrupt file operations
> -on this mount point. If neither option is specified (or if
> -.B intr
> -is specified), system calls return EINTR if an in-progress NFS operation
> -is interrupted by a signal.  If
> -.B nointr
> -is specified, signals do not
> -interrupt NFS operations.
> -.IP
> -Using the
> -.B intr
> -option is preferred to using the
> -.B soft
> -option because it is significantly less likely to result in data corrupt=
ion.
> -.IP
> -The
> -.BR intr " / " nointr
> -mount option is deprecated after kernel 2.6.25.
> -Only SIGKILL can interrupt a pending NFS operation on these kernels,
> -and if specified, this mount option is ignored to provide backwards
> -compatibility with older kernels.
> -.TP 1.5i
>  .BR cto " / " nocto
>  Selects whether to use close-to-open cache coherence semantics
>  for NFS directories on this mount point.


--Sig_/MFIHH3jtgzawt00O3OitVl_
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxl8aTnsnt1WYoG5AQLIBg//apH+wIiprc2HzXHgmcl2tmiXHsADulJ1
Sp6toIaZB7t09vQ+1vgo6bmwYR+fTHCPsFNA+4nbIoWicr5QRHkeHmOMm6PkdxFl
eMiCb9HoBOSRnhOblXm2Txvyhem9HvLL4VpQ0SKMc4RDHnJV40jx3zbilIf2sWEX
HHi1TFnZHC9ee95QtxJ6zsuQI/71y1lDY5jWLsb8deylmzWOgxIGBfwhi7HEmXd7
GhrJ3qkZLLdSKBJ0+DrJEaxDVyYIRoFzP0VISGOz7OdJV04j1WpBDgzO4IFkLzzP
WNypjxNXdG/mW1RJlJlhaM8iVCyFt9/Ie4QD4ww/sfmQAJaelRVE4tQ41NBtzzob
vyQ3ifzI2SIc2jPSoK3U49HyDpErft82+iPdaeG4YCgucriPhgw3L50W4uEFeHWD
k+uN0ahWjLyykIU74Krp6PX2ovb+9wqdTe4WpsKi9xNyfDi/5b0/SZDRWK03FkHR
ZfuhBZ68rTGvi2ljycn+/SQzRqJtinrfDWr/U70zhl2GulgOdQI40zkvRahHO1HI
x/qaHKHcSKadd9mwH7X87Ic8ohnIjZAzf9zuzRSjAt9m5Jlf/JRwpFjeOZYOILw4
bVCvslh+qlr+tVBqiCPpPO3thjnXdkU9yQ43YgcflPixEOIub5o4QOC1mEWdvErc
OAcKKr6w+IY=
=U9P0
-----END PGP SIGNATURE-----

--Sig_/MFIHH3jtgzawt00O3OitVl_--
