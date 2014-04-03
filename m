Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47366 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753142AbaDCWNd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2014 18:13:33 -0400
Date: Fri, 4 Apr 2014 09:13:24 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Boaz Harrosh <openosd@gmail.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Should exportfs/mountd cope with case-insensitive directory
 names.
Message-ID: <20140404091324.699d0ba6@notabene.brown>
In-Reply-To: <20140403213610.GF8343@fieldses.org>
References: <20140403164652.5d7770ad@notabene.brown>
	<20140403130909.GA24700@fieldses.org>
	<533D8629.10907@gmail.com>
	<20140403171625.GA5884@fieldses.org>
	<20140403172431.GB5884@fieldses.org>
	<20140404082154.4cfdab5a@notabene.brown>
	<20140403213610.GF8343@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/DB8IcIiNEhuM.JCsDWBmyfx"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/DB8IcIiNEhuM.JCsDWBmyfx
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 3 Apr 2014 17:36:10 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> (BTW:  I also noticed the other day that systemd is calling
> name_to_handle_at to get a mount id.  Seems like overkill in both
> cases--shouldn't there be a simpler way to get just the mount id?)

Yes, it is called "xstat" and is an extensible version of stat which even
includes a 'query' bitmap to list which things you want.

Unfortunately it never made it to mainline.  We should submit a patch to
systemd to get it to use xstat instead of name_to_handle_at.  That would
ensure that the kernel implemented it double-quick :-)

NeilBrown

--Sig_/DB8IcIiNEhuM.JCsDWBmyfx
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUz3dBDnsnt1WYoG5AQKnug/7BT8Aeq/z3FBO8yMkBvVx8xhvI28ZlQC+
v4reY0IEoVmnts7Nttfz4NQX469ybcz/aZmKfYjh4yLqRuHCZHVuIdYrdLwq3PX0
noIg9F7uFm1fx+yfFWG50T/4+UdTHlfhg3Rk7pZqHMDIsCr/NYppMRZD5EflGPha
fifZq5Taap5dvRDhVCA0Cgln0FnIaAGRsfTETupKuWZglJCPGTXSsZzDFI7v4Fuw
pLfeVSqVuUKKH3kRgMUwum+Gw1fFJ3MJIgDPQfEHw/S9GjVqRnYjcjiWDahI0Hl7
kgJR69NbZUn9x70KT/2iciksd6O9ZoEO38vGrC8LqJAmEWQ/3ObKEEDJpWe+9gRP
6mtRHov7D5xE3R7QrxlGKFvmMSGYPTzvArQ+Qrmb+gLXtSmeJjt5wkMisvGWzUm4
tAtTjvmOgrjYLIvt4PKgB2+xK10BGfm7vcOScc86qttr2kW5M2DYtSlS4mnpzR3d
H4GGSey8GWpWuqsN7gJArWfQ/cLTZ1GPN7RqdxmQIzJvPbiU8lhTOYAVMFnP11CY
6yWjfAoCk4KOFx0EtP3m4uP7u9qHl+k0hs6F2kfmligqz5xQUe1d1rR/Oj1KPpo4
dsMO7WdwxdnGXaSNXo2QkZqBvyHqG0gGjnpF5nDUtIrGqAlEIv8NGJU/vy1o0TPR
GPnYzu54c7s=
=mfhN
-----END PGP SIGNATURE-----

--Sig_/DB8IcIiNEhuM.JCsDWBmyfx--
