Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35692 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933573AbcKWXeS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Nov 2016 18:34:18 -0500
Received: by mail-io0-f195.google.com with SMTP id h133so3316702ioe.2
        for <linux-nfs@vger.kernel.org>; Wed, 23 Nov 2016 15:34:18 -0800 (PST)
Subject: Re: [PATCH xfstests] dirstress: Allow ESTALE as well as ENOENT
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: multipart/signed; boundary="Apple-Mail=_AC9128B0-4C8A-47DA-94EB-22E2128D442D"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20161123222054.GA7900@fieldses.org>
Date: Wed, 23 Nov 2016 16:19:11 -0700
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, fstests@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <35420A4E-1698-4743-9523-CBF43F2A2DC6@dilger.ca>
References: <20161123222054.GA7900@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_AC9128B0-4C8A-47DA-94EB-22E2128D442D
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

On Nov 23, 2016, at 3:20 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> In the NFS case an attempt to chdir out of a removed directory could result
> in ESTALE, and that should not cause the test to fail.
> 
> This was causing intermittent failures on generic/011 on NFS.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
> src/dirstress.c | 12 ++++++++----
> 1 file changed, 8 insertions(+), 4 deletions(-)
> 
> Sorry, who do xfstests patches go to?--b.

They are sent to fstests@vger.kernel.org

Cheers, Andreas

> 
> diff --git a/src/dirstress.c b/src/dirstress.c
> index f8f7355..33a166c 100644
> --- a/src/dirstress.c
> +++ b/src/dirstress.c
> @@ -203,8 +203,10 @@ dirstress(
>         if (verbose) fprintf(stderr,"** [%d] chdir ..\n", pid);
> 	error = chdir("..");
> 	if (error) {
> -		/* If this is multithreaded, then expecting a ENOENT here is fine */
> -		if (nprocs_per_dir > 1 && errno == ENOENT) {
> +		/* If this is multithreaded, then expecting a ENOENT here is fine,
> +		 * and ESTALE is normal in the NFS case. */
> +		if (nprocs_per_dir > 1 &&
> +				(errno == ENOENT || errno = ESTALE)) {
> 			return 0;
> 		}
> 
> @@ -224,8 +226,10 @@ dirstress(
>         if (verbose) fprintf(stderr,"** [%d] chdir ..\n", pid);
> 	error = chdir("..");
> 	if (error) {
> -		/* If this is multithreaded, then expecting a ENOENT here is fine */
> -		if (nprocs_per_dir > 1 && errno == ENOENT) {
> +		/* If this is multithreaded, then expecting a ENOENT here is fine,
> +		 * and ESTALE is normal in the NFS case. */
> +		if (nprocs_per_dir > 1 &&
> +				(errno == ENOENT || errno = ESTALE)) {
> 			return 0;
> 		}
> 
> --
> 2.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Cheers, Andreas






--Apple-Mail=_AC9128B0-4C8A-47DA-94EB-22E2128D442D
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBWDYj73Kl2rkXzB/gAQiYiBAAi7fRiG5K4CIgp6fOyseMuyJrmanA4pCZ
SJSHjq1f+q+sN33YqfZhf7zzpF67+HU49asgzy66Xrkfoc3r+pkvnKOtUAKbf7Vx
ASIyqYwLMtaYwjQ8B74wrvYnAMf78rQTLegO65UYYpP8PDjM4F06qPL4oFJip+cl
yKXRGSIw+TVkA23cVln7RpdbKH11CJOOY+Hf2WPpAsKDsg2MAa2TYNq61WL3h/QD
JnqJbsCJ1sRZp9yXEho/FDzNp1t/7J1rWIggcf4pRpd/fO40rkPfb1tbo2sGONne
24YzRQxcJzcVQDAXD419KjbIw2OyLrpz0oA8hXuW4qmmuJhFk4Xsr1xdi0++18HG
HYTwVKp88G7zaxOZWwQ0CARQy0B7VUpA4fEdIWwkaKcjjGN0SLx1F5dPkad7Qy34
S/OvyfQznArYF1lPdQSHhPOHM1TOFctEa2Ak7mfL9C2nCT82e98CiNuEAUrGMfRQ
qUQGPYFZzVwODhMVq7hLvzUrVaDgrUqJEmXgdKZCTGdtS9N897+P8SqFYjuvSvwV
xCq6gl40Np0h9+VyxrfXpvf6U3EpNK7Mxcr92YzPAcjEsaPfiwpfeBROe0CO+huI
I4U1W3ZiVaTcQ7IGwzb+WZuuOHWB421tL71J+wfRKeuiRNnTaSSct/DuJ1q+8XnR
7z7KyFeSLII=
=pgd+
-----END PGP SIGNATURE-----

--Apple-Mail=_AC9128B0-4C8A-47DA-94EB-22E2128D442D--
