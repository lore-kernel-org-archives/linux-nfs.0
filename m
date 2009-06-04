From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: libtirpc and nis
Date: Wed, 3 Jun 2009 20:12:20 -0400
Message-ID: <200906032012.21876.vapier@gentoo.org>
References: <200906031002.38551.vapier@gentoo.org> <200906031844.34398.vapier@gentoo.org> <047CD688-878B-4504-BD59-3C0B65C1B631@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1506055.CFrTTXEtxq";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	libtirpc <libtirpc-devel@lists.sourceforge.net>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:42966 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753489AbZFDAMV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 20:12:21 -0400
In-Reply-To: <047CD688-878B-4504-BD59-3C0B65C1B631@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart1506055.CFrTTXEtxq
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 03 June 2009 19:59:09 Chuck Lever wrote:
> On Jun 3, 2009, at 6:44 PM, Mike Frysinger wrote:
> > On Wednesday 03 June 2009 11:14:44 Steve Dickson wrote:
> >> Mike Frysinger wrote:
> >>> the libtirpc package is self described as a "standalone package".  i
> >>> wonder how far that actually goes.  wrt NIS, it requires the
> >>> system C
> >>> library to provide NIS functionality or you get a build failure in
> >>> a few
> >>> files.  would be nice if libtirpc were usable without any NIS
> >>> baggage at
> >>> all.
> >>
> >> NIS used RPC procedures to communicate. As it stands today
> >> NIS is currently using the RPC procedures glibc. In the
> >> future there is a very good chance that NIS will start
> >> using the RPC procedures in libtirpc especially if
> >> IPV6 support is needed...
> >>
> >> So I'm a bit confused on what you mean by "NIS baggage"
> >> in the libtirpc package.
> >
> > you cannot build libtirpc on a system that doesnt provide NIS
> > functionality.
> > realistic RPC usage today is NFS related services only (i.e. a NFS
> > client
> > mounting a share on a NFS server).
>
> Mike, it would help if you could provide the build output so we can
> see exactly what's failing.

libtirpc does not provide rpcsvc/nis.h
-mike

--nextPart1506055.CFrTTXEtxq
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iQIcBAABAgAGBQJKJxFlAAoJEEFjO5/oN/WBVmoQAMbvVAyhTvwJrl6cdMiPAf1o
aGWnfewbGyWwunqnHLRRe+ZzfGsHzmVu4jjR1rLoI7EDLBtOXBmyl2PiN9s0QYhV
YZKiGg2AMCcPD9c/NfX7Dk4U5N+meAk4UxzYQXz9XbGoNVfN5NlbMMPnS3wdfj2M
zYob1Xtfhkg9eNFC6KvIM4gcEBx+FYRsK1gbYR3EI5P3SgUUMlZSXssficLUhzFc
goSWa8vkxQRalsaWUEtgYdy9ibZ1UxkbbA+ocBc/jeiLyvTGJx+8hnvbIyXe1ZdU
TiYewMxgVvWYxOPAu9/8mbvtwY9kRB6FXgSKcXg6VSTZIJHgadf32lpzEOXG4/am
Ow5GXga/ztyC9m7rd+nYTNkML/8kGOP4YR6C93Vy7XT1Tf3HzxgD0sX9FVAXtOf1
j2N7akDQuhSfq5WCaVFpaSrKOZGBFyA0DT+qxjv2ZnD09hHimd9vn8WkxSI0a2ik
1L/BZU3vFkmH+SlaSxXqI1g/JdfN4OmCWGqv0HeUCiYpqD6+Hof8K/mkMJVPTksw
4oLaeryDPKWUyEmobKkP/dmbzM/vzlddX7Ph1ymu8QuI9bQ8v4n6g3yLSG12y6Tc
XtSe08iMy6ubFulDVWcW3qjjkZqAjFrMM6yuQu2US4okyVZrDLBGbwHrZETQnNsG
xVz4FjJqHgUt8a0jqpC7
=LmGS
-----END PGP SIGNATURE-----

--nextPart1506055.CFrTTXEtxq--
