Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59115 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751245AbdKHWfL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Nov 2017 17:35:11 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>
Date: Thu, 09 Nov 2017 09:34:59 +1100
Cc: Joshua Watt <jpewhacker@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>
Subject: Re: NFS Force Unmounting
In-Reply-To: <20171108155203.GK24262@fieldses.org>
References: <1508951506.2542.51.camel@gmail.com> <20171030202045.GA6168@fieldses.org> <87h8ugwdev.fsf@notabene.neil.brown.name> <1509557061.4755.27.camel@redhat.com> <87efphvbhy.fsf@notabene.neil.brown.name> <1509624549.4569.28.camel@redhat.com> <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com> <87fu9ph2g7.fsf@notabene.neil.brown.name> <1510142905.8401.6.camel@redhat.com> <20171108155203.GK24262@fieldses.org>
Message-ID: <87wp30flgs.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 08 2017, J. Bruce Fields wrote:

> On Wed, Nov 08, 2017 at 07:08:25AM -0500, Jeff Layton wrote:
>> On Wed, 2017-11-08 at 14:30 +1100, NeilBrown wrote:
>> > What to people think of the following as an approach
>> > to Joshua's need?
>> >=20
>> > It isn't complete by itself: it needs a couple of changes to
>> > nfs-utils so that it doesn't stat the mountpoint on remount,
>> > and it might need another kernel change so that the "mount" system
>> > call performs the same sort of careful lookup for remount as  the umou=
nt
>> > system call does, but those are relatively small details.
>> >=20
>>=20
>> Yeah, that'd be good.
>>=20
>> > This is the patch that you will either love of hate.
>> >=20
>> > With this patch, Joshua (or any other sysadmin) could:
>> >=20
>> >   mount -o remount,retrans=3D0,timeo=3D1 /path
>> >=20
>> > and then new requests on any mountpoint from that server will timeout
>> > quickly.
>> > Then
>> >   umount -f /path
>> >   umount -f /path
> ...
>> Looks like a reasonable approach overall to preventing new RPCs from
>> being dispatched once the "force" umount runs.
>
> I've lost track of the discussion--after this patch, how close are we to
> a guaranteed force unmount?  I assume there are still a few obstacles.

This isn't really about forced unmount.
The way forward to forced unmount it:
 - make all waits on NFS be TASK_KILLABLE
 - figure out what happens to dirty data when all processes have
   been killed.

This is about allowing processes to be told that the filesystem is dead
so that can respond (without blocking indefinitely) without
necessarily being killed.
With a local filesystem you can (in some cases) kill the underlying
device and all processes will start getting EIO.  This is providing
similar functionality for NFS.

>
>> I do wonder if this ought to be more automatic when you specify -f on
>> the umount. Having to manually do a remount first doesn't seem very
>> admin-friendly.
>
> It's an odd interface.  Maybe we could wrap it in something more
> intuitive.
>
> I'd be nervous about making "umount -f" do it.  I think administrators
> could be unpleasantly surprised in some cases if an "umount -f" affects
> other mounts of the same server.

I was all set to tell you that it already does, but then tested and
found it doesn't and ....

struct nfs_server (which sb->s_fs_info points to) contains

	struct nfs_client *	nfs_client;	/* shared client and NFS4 state */

which is shared between different mounts from the same server, and

	struct rpc_clnt *	client;		/* RPC client handle */

which isn't shared.
struct nfs_client contains
	struct rpc_clnt *	cl_rpcclient;

which server->client is clones from.

The timeouts that apply to a mount are the ones from server->client,
and so apply only to that mount (I thought they were shared, but that is
a thought from years ago, and maybe it was wrong at the time).
umount_begin aborts all rpcs associated with server->client.

So the 'remount,retrans=3D0,timeo=3D1' that I propose would only affect the
one superblock (all bind-mounts of course, included sharecache mounts).

The comment in my code was wrong.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAloDhpUACgkQOeye3VZi
gblnkA/9Eu9kGnBzUxJrH0Nbfk1x0T39jS/AL/XPHy/KA8jw2On7eh0AKk3pMq2s
tsGnpKgjh8eceVdZpeR37apdZFsCKHDHhKfa37434HqiywPaGjrpyVf1Fx3zPBtb
0nyKGPaFfqP+WWl15qIiNtKuMZU7y/J6a5vy5NgZbtQeCg0YcNKwKMlwiTC7oYWL
MUy+WuY65NsvsAojuhfXWip39pGqVXRfcYh7aZNlSXiHuOw+tEAi7HZKCUtg3S9G
5u7v2Lntdz57v+Wb2kQPKF0fWKvYZQbF52JjKWz0d/SxbRSdl2tOA5gUfBkpM5jW
o9dE7zqYPQ2uhq/sJ30hCJHpVnah6VHXR3/dN7zJrzcyB4rf7t7tiuu/4alKA79t
b+T8cFDXPqKm2HcJNO+I5JOnweu6ASlu9QIVYuahtTFCQ9m26l2KN6GGeAXTKfmJ
6Jp0WQH/OIaS3zl3UcorxWM6SMMUdpvMFMUoz5Q5c+L53lStCiHA6GUZ0FYFoj+e
pgswocBhMYob4kuX+GdKjjvHjc6TKzvb0tCFOv410zqfPgXsaJw0hNJYZqy5lYbI
ghkOlU1DhuQMrlSVMFF5zpKXc3scXOkgGTLITTvVcMh+zuTJe00hILZxtZ9P+ury
cn7XzQNBLzbhFz1sc5Q4PBCRD4HXoiOkGjRQLdMpAHu8T6pUWwg=
=XuLk
-----END PGP SIGNATURE-----
--=-=-=--
