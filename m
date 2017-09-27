Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48172 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752050AbdI0WZS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Sep 2017 18:25:18 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 28 Sep 2017 08:25:07 +1000
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
        "Daniel P. Berrange" <berrange@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Matt Benjamin <mbenjami@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Justin Mitchell <jumitche@redhat.com>
Subject: Re: [PATCH nfs-utils v3 00/14] add NFS over AF_VSOCK support
In-Reply-To: <20170927133534.GA9585@fieldses.org>
References: <20170919164427.GV9536@redhat.com> <20170919172452.GB29104@fieldses.org> <20170921170017.GK32364@stefanha-x1.localdomain> <d760ecdc-988d-8145-f816-6faf8f2abf03@redhat.com> <E5B4D2FF-0DB4-417D-998A-6BBFC36C35C5@oracle.com> <20170922115524.GN12725@redhat.com> <87efqu6wl4.fsf@notabene.neil.brown.name> <20170926034026.GA19283@fieldses.org> <20170926105626.GH16834@stefanha-x1.localdomain> <87bmlx6kbm.fsf@notabene.neil.brown.name> <20170927133534.GA9585@fieldses.org>
Message-ID: <8737777pa4.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Sep 27 2017, J. Bruce Fields wrote:

> On Wed, Sep 27, 2017 at 10:45:17AM +1000, NeilBrown wrote:
>> My idea is that the "root" network namespace is only available in early
>> boot.  An NFS mount happens then (and possibly a daemon hangs around in
>> this network namespace to refresh the NFS mount).
>
> I think they also want to be able to do mounts after boot.

Hence "a daemon hangs around ... to refresh the NFS mount" by which I
meant to imply the possibility of creating new mounts as well.

That may be unnecessary.  It might be safe to allow processes to move
between the network namespace.  We still don't have a clear statement of
the threat model and the degree of isolation that is required, so it is
hard to create concrete recommendations.

Thanks,
NeilBrown

>
> I assume you either keep the mount namespace shared, or use mount
> propagation of some kind.
>
> --b.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlnMJUUACgkQOeye3VZi
gblWiRAAtzJQ9NyoQx6H3bezOYCF7+VcNvOB1L7Uq0L/yfxOYczdMyo7KSb9+7Lu
fsQLiCbM5FzUQPBWAj9cVPEFT+H4ncWavQv47Md4MrFwx4Xpsj+XKkUp8zhMcmAI
3GmYWocwMRcHMPwhZbi82YBMgUlNJmGA8wubVax7eHGVuFZ8XAeViq6zDkHZhck+
dV/v34A2zUjtpgTDrVJSJo+ggXU9uIR7vF+WFe5VAy0xEcOZgxJbSqVN/oAi8BfU
nB6z+mmpr/ytwuCo5kV9k/1Hg2nImGp4M4wbm7tH6LvzD1pSc6wHuAQnZvkquzvY
M8W8musJR1/C3z6Da3x5wXp4yoFI1qtDX5X6lsrwrK6fKrp6zl2jyeL2ULukk9cu
Lgp7kUmi7iQ3o8wVcJmS0By68JsnczAiul4rjwdZ7dbnVVZkIdwSN+d3fXerC0oK
HkcPXUK7b9KyXABfBpYtz2rdXXm8e0pub4pXE5sq+zfYwsZFHRXFW07eTH+I1R1w
EZPx2G5iuveUXb53PBzxlQBhHtGuCioUbbL9ugtjxi0HGalt0TIxYS6oDy7UDhn+
TFEV6AuqxXfVnMbHwiKgTowML/R6tvjHdtz1dbpIEMipyEBYA53HCaAnvPTRVjq2
6tJntBJXh7Ey5pNCFan1XnZTh4SXjv6t+NBT5K2dqiN8tNsjj4M=
=Wuk9
-----END PGP SIGNATURE-----
--=-=-=--
