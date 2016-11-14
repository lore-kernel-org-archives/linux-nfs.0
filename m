Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:41926 "EHLO smtp.gentoo.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935180AbcKNUMd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 Nov 2016 15:12:33 -0500
Date: Mon, 14 Nov 2016 12:12:31 -0800
From: Mike Frysinger <vapier@gentoo.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: NeilBrown <neilb@suse.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Subject: Re: [Libtirpc-devel] [PATCH rpcbind] Move default state-dir to
 /run/rpcbind
Message-ID: <20161114201231.GX21655@vapier.lan>
References: <877f8almcf.fsf@notabene.neil.brown.name>
 <20161111210034.GM21655@vapier.lan>
 <87polzj7sx.fsf@notabene.neil.brown.name>
 <20161114191234.GV21655@vapier.lan>
 <8cbf8fc2-d358-37ca-75cf-c4e85e7aa3a4@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="RBwhyBAm9PDPRYWT"
In-Reply-To: <8cbf8fc2-d358-37ca-75cf-c4e85e7aa3a4@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--RBwhyBAm9PDPRYWT
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On 14 Nov 2016 14:26, Steve Dickson wrote:
> On 11/14/2016 02:12 PM, Mike Frysinger wrote:
> > On 14 Nov 2016 10:09, NeilBrown wrote:
> >> On Sat, Nov 12 2016, Mike Frysinger wrote:
> >>> On 11 Nov 2016 14:36, NeilBrown wrote:
> >>>> rpcbind can save state in a file to allow restart without forgetting
> >>>> about running services.
> >>>>
> >>>> The default location is currently "/tmp" which is an over-used
> >>>> directory that isn't really suitable for system files.
> >>>> The modern preferences would be a subdirectory of "/run", which can
> >>>> be selected with a ./configure option.  That subdirectory would still need
> >>>> to be created by something.
> >>> the portable path is /var/cache instead of /run.  i don't think libtirpc
> >>> should be configuring itself to assume Linux by default.
> >> In principle I agree.  But is /var/cache really a good choice?
> >> We don't want the state files to persist over a reboot, and I strongly
> >> suspect that /var/cache is designed to do exactly that.
> >>
> >> Are there agree standards that are broader than Linux that we can look
> >> to?
> >> FHS defines /var/run (or even /run) but I suspect it is linux-only.
> > /var/run should work across systems i believe.  at least BSD's support it.
>
> In the Red Hat distos /var/run is a symbolic link to /run and the systemd
> folks have asked us to use /run instead of /var/run

yes, but we already know that's not an acceptable default -- /run today
is Linux specific.  the question i was responding to here is if there's
a portable location that is better than /tmp.

Linux distros already know that for many packages they need to pass
flags to get /run behavior.  rpcbind is no different.
-mike

--RBwhyBAm9PDPRYWT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYKhqvAAoJEEFjO5/oN/WBjYcQAKgIbeksGhTQw+jp1TMW6lGA
WG4CNgGaCeVrOCtEvDGMTk85sH8wbJeraj43Cima6+Wbg58scGzN2q/A1aytscix
Lifr4rR3Z6pC8OwLgNg2X9JDqVJIadlCzCO2T+E68fb3sJaXVJYW0NV44yb9k7Ri
i40O8R11NkJOkkmN5SYjyVACTXRJ5s+ISjNMSsXSBtDjmo0WML5/gzvh3J5i61Qo
OqxI3DE82VP9ouZjStIU9D49Hrfz0G65zeQhm5xczF3Rerh9Mob27qHf0JnPMlqk
RJLZAcRV96OplaEbn46Mc2Ox2ByxVt60WJqShHERai3bMh47rhL5Yvu+fjdXa298
ouYP8YnNxiTtHxSmLTUqwDnDjGFGSAwrmns4ttw5IWHKjCPoSWfZ4Wno4/VD8MgS
2CoYTM0ZT3FVU6dbb0n19JdORpMu16Bxy0vQ7JjG079DbtxeBhsxGU1JTsBhiRvd
Dq09NsiP0dgpiNKGUQk3dd7+SIRREsfNu1q5GtgCqMTBMN0MziP2YRDtW3wchJFa
EDGOyr5z5Gy/Tc+mhw9xzCZP8x/c8RixLSY7WKfScssl3I1TbPeg6tG+9Ylb9Z0f
L33SQUERjs12dK4u9d3h3doUrrbqCR1JcDi4RoUElpIrB3HJ9yLEpD+YZyX3BWDL
nxvkZz6bY1HM4Cy8tFw6
=1399
-----END PGP SIGNATURE-----

--RBwhyBAm9PDPRYWT--
