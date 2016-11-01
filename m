Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46914 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754301AbcKAUEO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Nov 2016 16:04:14 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 02 Nov 2016 07:04:07 +1100
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH - rpcbind] Provide systemd unit files for rpcbind
In-Reply-To: <8c1fa65d-9efc-462a-b6c8-7ed518f0dfe4@RedHat.com>
References: <87oa2q14yc.fsf@notabene.neil.brown.name> <8c1fa65d-9efc-462a-b6c8-7ed518f0dfe4@RedHat.com>
Message-ID: <87r36vq85k.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 02 2016, Steve Dickson wrote:

>> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
>> new file mode 100644
>> index 000000000000..4706b5a77abf
>> --- /dev/null
>> +++ b/systemd/rpcbind.service.in
>> @@ -0,0 +1,17 @@
>> +[Unit]
>> +Description=3DRPC Bind
>> +Documentation=3Dman:rpcbind(8)
>> +DefaultDependencies=3Dno
>> +RequiresMountsFor=3D/var/run /run
>> +# Make sure we use the IP addresses listed for
>> +# rpcbind.socket, no matter how this unit is started.
>> +Wants=3Drpcbind.socket
>> +After=3Drpcbind.socket
>> +
>> +[Service]
>> +Type=3Dnotify
>> +# distro can provide a drop-in adding EnvironmentFile=3D-/??? if needed.
>> +ExecStart=3D@_bindir@/rpcbind $RPCBIND_OPTIONS -w -f
> This macro puts rpcbind in /usr/bin, but in the Red Hat
> distros rpcbind lives /usr/sbin. I could easily patch
> it to do the right thing... but is this a typo or does=20
> rpcbind live in /usr/bin in other distros?=20

oops, posted previous reply too quickly.

Hmm.. I have rpcbind in /sbin, but my rpm spec file
runs configure with "--bindir=3D/sbin"
The rpcbind makefile just installs rpcbind (and rpcbind) in bindir.
So presumably you run configure with --bindir=3D/usr/sbin ??

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYGPU3AAoJEDnsnt1WYoG5bHkP/1i+p4/CoiPC/EMNUmiur5wE
mLeSMAeVCHst6HXX/wByC0svcW5tzBOzjQsTyXyXNkQY+FAl55q3hiH5qdy3OmSF
lFHdsz14GxTY4x+Ej263Jcc3l+43/kjluvaBsrOj10ax9o48gCGjVXgVTh37Wc+k
HllV+u0ZQ9VHiLI6gc+BDKoHMO36BXYWeR4us3mX0DVlt7EtWSRP2i9nqWkesd6V
hXRQ3Usu8Kn77QKsnq8SP9EDXaa2RhvhbhelWK1DEGcBeO3WB70TbldUviQyzBZI
7H8BF7XCasMuSiWXTa2LfdCWH1hCuisNZObXljFIK6ysnpzSsE7kM0uND+z2AkhQ
ta7sCy3bphBR5iyplfQN2Ck0lKlTJCVPRYn44DvuU1dJWMlllolcE7fBQv2l4dDE
5CupLTYQ8/ww+itaUUcbfeol+TVWNwIJ0pVp9UEVFakmLBN7UuhXIIbNu5PjGFsG
NuJxir/e/hjJB1zSI/2oeEHG2EfLoFjFRI6CGftZk7ILRDp/fgiwegQkEnP7iU/K
yCk5Wlh41axFfKvquI+kHNy7S3DmbI63HokMKqj1FXENua2ur6ehTUOMUK+YBtxP
q55UoggzXtEhc1LEeFF3s+wYF096pbovdw+QzEfFaFkNL5AFSdq5TrEcyNuFPE/k
Uszx0pw7DNVUvnzGXJEP
=yaT9
-----END PGP SIGNATURE-----
--=-=-=--
