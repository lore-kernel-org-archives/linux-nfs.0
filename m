Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34400 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754242AbdKJARA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 19:17:00 -0500
From: NeilBrown <neilb@suse.com>
To: Joshua Watt <jpewhacker@gmail.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "bfields\@fieldses.org" <bfields@fieldses.org>,
        "jlayton\@redhat.com" <jlayton@redhat.com>
Date: Fri, 10 Nov 2017 11:16:47 +1100
Cc: "viro\@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dhowells\@redhat.com" <dhowells@redhat.com>
Subject: Re: NFS Force Unmounting
In-Reply-To: <1510256899.2495.20.camel@gmail.com>
References: <1508951506.2542.51.camel@gmail.com> <20171030202045.GA6168@fieldses.org> <87h8ugwdev.fsf@notabene.neil.brown.name> <1509557061.4755.27.camel@redhat.com> <87efphvbhy.fsf@notabene.neil.brown.name> <1509624549.4569.28.camel@redhat.com> <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com> <87fu9ph2g7.fsf@notabene.neil.brown.name> <1510142905.8401.6.camel@redhat.com> <20171108155203.GK24262@fieldses.org> <87wp30flgs.fsf@notabene.neil.brown.name> <1510185172.9891.18.camel@primarydata.com> <1510256899.2495.20.camel@gmail.com>
Message-ID: <87tvy3dm34.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 09 2017, Joshua Watt wrote:

> On Wed, 2017-11-08 at 23:52 +0000, Trond Myklebust wrote:
>> On Thu, 2017-11-09 at 09:34 +1100, NeilBrown wrote:
>> > On Wed, Nov 08 2017, J. Bruce Fields wrote:
>> >=20
>> > >=20
>> > > I'd be nervous about making "umount -f" do it.  I think
>> > > administrators
>> > > could be unpleasantly surprised in some cases if an "umount -f"
>> > > affects
>> > > other mounts of the same server.
>> >=20
>> > I was all set to tell you that it already does, but then tested and
>> > found it doesn't and ....
>
> I tried mounting two different remote paths from an NFS4 server, and
> when I did 'remount,retrans=3D0', it changed the parameter for both of
> them meaning they are indeed shaing the struct nfs_server (which based
> on my reading of the code is what I would have expected). What
> procedure did you use to test this?

I was using nosharecache, because I was thinking "of course it will
affect all mounts that use sharecache, that is really the same as
a bind-mount".  But I should have been explicit.

With nosharecache, "umount -f" or remount only affects the one mount.
With sharecache (the default) or bind mounts, "umount -f" and remount
affects the underlying superblock which might be mounted at multiple places.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAloE7/EACgkQOeye3VZi
gbmRhRAApTneX7UmGZevYvhKKUmHFf+4ljdbDnfbrdZ8IsMht7EfwDumP5HcfMDS
NNJ+bm7RNghyxpBlXLK4h30bUnN+7gvWkhjcbPKqPvilH8cLgXvzXuRk3nHpaSTE
4UhE9xRii0GbpFz+XFJzOXOHx05uFsLBt3hzN9CDWFVEIP3xSrlV4oaqBen+sbs6
Zb3ajtRzLDBvEWabo6inHkjLrKrJqH2HUXPa3u8AbC9qQn8KJ96AtN1peqRCoN0r
RWq467zoGM+CdcJxUQ3qwQl0xbb5iw/1ATVdxEveYRKNv57VZrL0OMOESyeTuTdd
FS8oOYyb4fqWUT1ERHL7bmRehmYadqa+AnGeZ0G0E2Ta0s7yYmYtERsyydPuRcxE
pkFccOfDQxNuDr2eAKhP1j/ubF+33+Qk6YY5goYtCw2h1IP6zcn0sdNXLebR8ozW
NSbCPWcad7SoCeXt90kT3271Dbr2LdvbHUhTa6QjLoZ+IRoBF2GOrZWYMesQOWAQ
4Q07WaVxvihKz0cCqehhOvYTQREFfR1i9addF5xrl+U0oFS6wb5OSAx2Lna6p6+0
cESetjzY7Dmd/sU3RLr0iYpYOWHtQosrtmrVFkdZgE4zVivxVSMh5Dvg0rZIzbBs
yNxtYXUvuPz5LZZjvRXaY7r6gE0+6bapzgkltz1P2rDvUxkPoOM=
=D8nh
-----END PGP SIGNATURE-----
--=-=-=--
