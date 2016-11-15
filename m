Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41707 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751605AbcKOGgT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Nov 2016 01:36:19 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Tue, 15 Nov 2016 17:36:10 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Subject: Re: [Libtirpc-devel] [PATCH rpcbind] Move default state-dir to /run/rpcbind
In-Reply-To: <669e90b0-6011-7b82-4e37-f1e3bf292026@RedHat.com>
References: <877f8almcf.fsf@notabene.neil.brown.name> <669e90b0-6011-7b82-4e37-f1e3bf292026@RedHat.com>
Message-ID: <87k2c5i71h.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Nov 15 2016, Steve Dickson wrote:

> On 11/10/2016 10:36 PM, NeilBrown wrote:
>> rpcbind can save state in a file to allow restart without forgetting
>> about running services.
>>
>> The default location is currently "/tmp" which is an over-used
>> directory that isn't really suitable for system files.
>> The modern preferences would be a subdirectory of "/run", which can
>> be selected with a ./configure option.  That subdirectory would still need
>> to be created by something.
>>
>> It is trivial for rpcbind to create the directory itself, and harmless
>> to try if it already exists, so:
>> - add a "mkdir" when saving state data
>> - change the default to /run/rpcbind (currently used by Debian)
>> - remove the default settign in the code, just use the one
>>   in configure.ac
> I'm all for move the warmstart directory to /run but why don't we have systemd
> create the directory via a  tmpfiles.d( config file... some like
>
> #Type Path      Mode UID GID Age Argument
> D  /run/rpcbind 0700 rpc rpc - -
>
> The only thing I'm not sure about is how it would get installed...
> I guess it would some type of Makefile.ac entry??

Because not everyone uses systemd?

Someone at SUSE recently moved the state directory to /run/rpcbind and
used tmpfiles.d exactly as you describe to create /run/rpcbind.  Then
found they needed to do something extra and different for dracut.  I
haven't looked into why, but it is presumably because while dracut does
use systemd, it doesn't use it quite the same way that normal system boot
uses it.
I've found this with configuring mdadm too.  I got the udev and systemd
configuration just right, and then found that while dracut uses udev and
systemd, I still need to add extra stuff to dracut.  And then there was
another boot environment which used udev but not systemd, so it needed
different tweaking.

So I think we are less likely to run into strange problems if we just
get rpcbind to create its own directory.  Certainly rely on systemd to
do the things that systemd does best (like start the service), but don't
rely on it to do things we can easily do ourselves.

Thanks,
NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYKqzbAAoJEDnsnt1WYoG5lhkP/0EUCP5J5xFYNyLSvA5j+IA1
lWOPLDWG7KIuv9dnsquJR4/mKVKDDv3WH2/K+M6PsreNAtb3h0es21CEHebmdEyb
E2mEt68cJvy/klwOogxffv6ybgx5Bbhd/ZPqyF9mDdScDJh/sQFIPjfXHhIYNZOk
V8lNYCJpaonTnM7d2nAkq2PUxugtauOhfTxHKUJ2sary3mN4WX+DqUFCW/eOxuqI
7txeAIeWkunYSHUsGDPeAbbG18Bf6MqFafV1RH5PC60b2ukKMrjBVEwtDhZmlUS4
+dMLvj8iqhscvbrIMxwdfT3wuf1RfIcaFAqvkgpBFsdDR4RYjxFdF2GvZ9XAUOHw
hCicEVwfziY/gVCL1BpO9HiD1yOIDN654UFYa6mPIAzp8G+pM7xkfexhEMxe8+jP
UIGHeUUUDvwIBMH1pRwiRm9AuD296Y3E0qKl+NCuJGrJRDjVXEWJRak2Vf0ZNHeR
7qgW3VAtgQsUo0V1H6T29bsu60ZKkRnSCERMJVRb0+w6AxyJM6XqT/V10+6erlxp
lIbNWZV2dEli0YbzGPICzIvhPGZ8MO81MM/++X/KRci0Al+MgN5ECtEw5g+0VJ/t
GsaKjpnUYhERu4Ke6JMfW0e0famvF4iycyN7GMBE8IUUnUKaM1/R9eFD/QIeAEhb
NoZyWgSj9tpud27c++j1
=XazR
-----END PGP SIGNATURE-----
--=-=-=--
