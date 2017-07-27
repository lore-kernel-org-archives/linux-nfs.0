Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60861 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750759AbdG0Ehd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 27 Jul 2017 00:37:33 -0400
From: NeilBrown <neilb@suse.com>
To: Phil Kauffman <kauffman@cs.uchicago.edu>, linux-nfs@vger.kernel.org
Date: Thu, 27 Jul 2017 14:37:22 +1000
Subject: Re: /etc/mtab read ~900 times by rpc.mountd
In-Reply-To: <03636068-4cc7-896e-5f8b-8c3ebfd2aa94@cs.uchicago.edu>
References: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu> <8737a9x9ky.fsf@notabene.neil.brown.name> <595F1A3A.7070405@cs.uchicago.edu> <87efto69rs.fsf@notabene.neil.brown.name> <4ec2a8fc-3ca5-d26b-7742-be4e2f749c21@cs.uchicago.edu> <87y3rv4zrb.fsf@notabene.neil.brown.name> <1740081e-6180-1c88-0a0c-8747a92c65a1@cs.uchicago.edu> <87bmoq4h41.fsf@notabene.neil.brown.name> <9e16d6c3-a675-b53e-c6f3-dfa9cdf1d5c9@cs.uchicago.edu> <871spj1pfr.fsf@notabene.neil.brown.name> <03636068-4cc7-896e-5f8b-8c3ebfd2aa94@cs.uchicago.edu>
Message-ID: <87h8xywl4t.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 25 2017, Phil Kauffman wrote:

> On 07/14/2017 01:51 AM, NeilBrown wrote:
>> Please try this (against a clean nfs-utils.  i.e. remove the previous
>> patch).
>> It is a hack and would need to be totally re-written, but hopely the
>> measurements you make and strace that you report could be useful.
>> Also, for the strace, please use "-ttt" rather than "-tt" like I asked
>> before.  It is easier to find the difference between two times with
>> -ttt. And add -T as well.
>
> Sorry this took so long but I had to be sure of my results.

It is worth being thorough.

>
> With your latest patch applied I am unable to mount my NFS shares and=20
> thus continue with the tests from before.

Weird.

You are experiencing a bug that was very recently fixed, where if
mount.nfs4 gets the error ENOENT from the server, it falls back to
NFSv3.
That explains some of the noise, but doesn't explain why you get ENOENT
for the v4 mount.

The strace output you've provided doesn't even show any attempts to read
/etc/mtab, which my patch doesn't change at all.  So it seems like the
context is different in some way.

Your nfs_test_notes.txt doesn't show /etc/export.d getting filled in
... maybe that it done automatically somehow...

Can you try with unpatches 2.1.1?
Also maybe provide an strace starting before any attempt to mount
anything, and with an extra option "-s 1000"..

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAll5bgQACgkQOeye3VZi
gbmz8A//bPhx29MBduHDYmOCkStEF5HTE16fZStjddSizU7FOltVLuvUL9HhAS1j
rHmMwVyC+uowuI2fjZmwHHQxZbSTCuAPZHXo8XwpipE/niE/kRqDQPKkRz+Z5Q3V
B9hstgFIGbtpgwbPCBDi42XrOEj89zVRMlZHKAhV+IrgYqAWnvjd3OTb6ndbu5OP
EPCXiPfX/ovqrHltfAFwDHBqc57dss+eRyXixiuBLhc5OJvOttXA8hbu/seBCtD4
dm5uZ371KSPl43TNWA854y2YO9U2Janh3lVZJ9ZjtnPAnIkko6lMIHiUf4JBu9Oz
jUj9ispMzSzHiXtB/5G2IXDEzJI7Fggg30rF1W3voNXbU8FXmP8UESktqMozelxD
v1zdjEWVYqn4LbdrHJOEPSyWXR+RSS2C6tj53Pc0XXay6w1AUe0mhM2s11lFfjHn
tzQQXVuizvXCh7W4cey6AuNiyTF+TKN/cPE8GW2nY9DSD5U8aNQjvDkxlhieImxD
VQQMtu47437B+RBZ0COlzh+55+p3EiPSLIt2nCEUU1JG35mg8y2zIzXekr5vkRvZ
RsMtYD/nbgj4/ou5a/M7tF7h/uxbYxIbe7f/rgmbKUblR3gUMkTDthKehTUCb9mT
ggGXjQWY0mFhfSgbZeIvVQkGZrlj0cPTTN3zg7aR6RbXb4vOTe0=
=sUtz
-----END PGP SIGNATURE-----
--=-=-=--
