Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:53737 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958Ab1LAICh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 03:02:37 -0500
Date: Thu, 1 Dec 2011 02:02:27 -0600
From: Tyler Hicks <tyhicks@canonical.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        David Howells <dhowells@redhat.com>, Jan Harkes <jaharkes@cs.cmu.edu>,
        "maintainer:CODA FILE SYSTEM" <coda@cs.cmu.edu>,
        Dave Kleikamp <shaggy@kernel.org>,
        Petr Vandrovec <petr@vandrovec.name>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Greg Kroah-Hartman <gregkh@suse.de>, Chris Dunlop <chris@onthe.net.au>,
        v9fs-developer@lists.sourceforge.net, linux-afs@lists.infradead.org,
        codalist@TELEMANN.coda.cs.cmu.edu,
        jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org,
        ecryptfs@vger.kernel.org
Subject: Re: [PATCH 1/1] fix d_revalidate oopsen on NFS exports
Message-ID: <20111201080227.GC495@boyd>
References: <1321861008-20611-1-git-send-email-chris@onthe.net.au>
 <20111129082501.GA569@onthe.net.au>
 <20111201065024.GB495@boyd>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="Izn7cH1Com+I3R9J"
In-Reply-To: <20111201065024.GB495@boyd>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Izn7cH1Com+I3R9J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On 2011-12-01 00:50:25, Tyler Hicks wrote:
> As David mentioned, Al's atomic open patches might solve all of this in
> the future, but I don't know much about that patchset. Is there any
> relevant info you could provide about those patches, Al?

Sorry, Al. I see that you've already provided those details here:

https://lkml.org/lkml/2011/5/12/337

I was unaware of that thread until now.

Tyler



--Izn7cH1Com+I3R9J
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCgAGBQJO1zSTAAoJENaSAD2qAscKAe8P/086rTItWBFlIGAa/AjG+urt
8bUVX+Sy/nVtqUzzoO+yNShUwunB1FoS3LqpkrRziXcmlAzghmBDR6r67kg/GIbX
WmWPjCF+0aLvTCxLTpjtjxzd8Fqcp8CoaFVR4Pt42qmRhvrG2aqXW3y4REH/ERME
3VJT5LCqgdzxHq8G1nc9ushgcnJBUp8FVAIfUx1CFY/BzBV/wIKyoXP9kpOQJCPQ
pm9tj7nUGIj5BiNThHyDVM5QomCDNKiQQNLxnQHFU0qIfPbOpQQY1O+ZGXLqan5l
wQjtFmuqSlyew2XVahJg5q6c6gXcP+MkBlgSJ7UQ7yYhlR9e5eGxTrWAWRg429Px
RKzV646mO4yHLy5EO/zC7yHP/7QLKgUg27cgI1RgnZHhClbJAbPfPVbK1tbs+WVE
zUEgsSAgcn/YOOslnH13bd8TT/MEYIxNoFxIIYCJ48QxU+bcPoYUSmz+eVOZ6Bn7
ZfX/Lw0NtDud4D4G7FxcTMcOApk4cOhtS7xqKRI7fFNmoxUQcXY12Gy/evCAX0uN
MNUQONf4n5chc+kIWT8++maOU2DwlBpSgHDgigrvvGhXF4vo7MIHv7PJPkHsMA/K
atbRpNm79AVRKCAah0nSmFTz19WtAi1rk46+8VOqeN4Rk/GixQpi3OUI5xYVTr5r
eH4FmWAbr4wo1ciSE2E2
=7Kyp
-----END PGP SIGNATURE-----

--Izn7cH1Com+I3R9J--
