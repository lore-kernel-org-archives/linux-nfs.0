Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46397 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753072AbdLEXef (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Dec 2017 18:34:35 -0500
From: NeilBrown <neilb@suse.com>
To: Joshua Watt <jpewhacker@gmail.com>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Date: Wed, 06 Dec 2017 10:34:25 +1100
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>
Cc: linux-api@vger.kernel.org
Subject: Re: [RFC v4 0/9] NFS Force Unmounting
In-Reply-To: <1512398194.7031.56.camel@gmail.com>
References: <20171117174552.18722-1-JPEWhacker@gmail.com> <1512398194.7031.56.camel@gmail.com>
Message-ID: <87indksq9q.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 04 2017, Joshua Watt wrote:

> On Fri, 2017-11-17 at 11:45 -0600, Joshua Watt wrote:
>> Latest attempt at unifying the various constraints for force
>> umounting
>> NFS servers that have disappeared in a timely manner. Namely:
>>   * umount2(..., MNT_FORCE) should not be made stronger, unless we
>> know
>>     this is the final umount()
>>   * The "failed server" state should be reversible
>>   * The mechanism should be able to "unstick" a sync(2) that is stuck
>> on
>>     an unresponsive server
>>=20
>> I believe the proposal satisfies all of these concerns. There are a
>> few
>> major components to this proposal:
>>  1) The umount_begin superblock operation now has a corresponding
>>     umount_end operation. This is invoked by umount() when MNT_FORCE
>> is
>>     specified (like umount_begin()), but the actual unmount failed
>> (i.e.
>>     the mount is busy).
>>  2) Instead of killing all the RPC queued at a single point in time,
>> the
>>     NFS mount now kills all queue RPCs and all RPCs that get queued
>>     between nfs_umount_begin() and nfs_umount_end(). I believe this
>> is
>>     not a significant change in behavior because there were always
>> races
>>     between queuing RPCs and killing them in nfs_umount_begin().
>>  3) nfs_umount_end() is *not* called when MNT_DETACH is specified.
>> This
>>     is the indication that the user is done with this mount and all
>>     RPCs will be killed until the mount finally gets removed.
>>  4) The new "transient" mount option prevents sharing nfs_clients
>>     between multiple superblocks. The only exception to this is when
>> the
>>     kernel does an automatic mount to cross a device boundary ("xdev"
>>     NFS mount). In this case, the existing code always shares the
>>     existing nfs_client from parent superblock. The "transient" mount
>>     option implies "nosharecache", as it doesn't make sense to share
>>     superblocks if clients aren't shared.
>>  5) If the "transient" mount option is specified (and hence the
>>     nfs_client is not shared), MNT_FORCE kills all RPCs for the
>> entire
>>     nfs_client (and all its nfs_servers). This effectively enables
>> the
>>     "burn down the forest" option when combined with MNT_DETACH.
>>=20
>> The choice to use MNT_FORCE as the mechanism for triggering this
>> behavior stems from the desire to unstick sync(2) calls that might be
>> blocked on a non-responsive NFS server. While it was previously
>> discussed to remount with a new mount option to enable this behavior,
>> this cannot release the blocked sync(2) call because both
>> sync_fileystem() and do_remount() lock the struct superblock-
>> >s_umount
>> reader-writer lock. As such, a remount will block until the sync(2)
>> finishes, which is undesirable. umount2() doesn't have this
>> restriction
>> and can unblock the sync(2) call.
>>=20
>> For the most part, all existing behavior is unchanged if the
>> "transient"
>> option is not specified. umount -f continues to behave as is has, but
>> umount -fl (see note below) now does a more aggressive kill to get
>> everything out of there and allow unmounting in a more timely manner.
>> Note that there will probably be some communication with the server
>> still, as destruction of the NFS client ID and such will occur when
>> the
>> last reference is removed. If the server is truly gone, this can
>> result
>> in long blocks at that time.
>>=20
>> If it is known at mount time that the server might be disappearing,
>> it
>> should be mounted with "transient". Doing this will allow mount -fl
>> to
>> do a more complete cleanup and prevent all communication with the
>> server, which should allow a timely cleanup in all cases.
>>=20
>> Notes:
>>=20
>> Until recently, libmount did not allow a detached and lazy mount at
>> the
>> same time. This was recently fixed (see
>> https://marc.info/?l=3Dutil-linux-ng&m=3D151000714401929&w=3D2). If you
>> want
>> to test this, you may need to write a simple test program that
>> directly
>> calls umount2() with MNT_FORCE | MNT_DETACH.
>>=20
>> Thank you all again for your time and comments,
>> Joshua Watt
>>=20
>> Joshua Watt (9):
>>   SUNRPC: Add flag to kill new tasks
>>   SUNRPC: Expose kill_new_tasks in debugfs
>>   SUNRPC: Simplify client shutdown
>>   namespace: Add umount_end superblock operation
>>   NFS: Kill RPCs for the duration of umount
>>   NFS: Add debugfs for nfs_server and nfs_client
>>   NFS: Add transient mount option
>>   NFS: Don't shared transient clients
>>   NFS: Kill all client RPCs if transient
>>=20
>>  fs/namespace.c                 |  22 ++++++-
>>  fs/nfs/Makefile                |   2 +-
>>  fs/nfs/client.c                |  96 +++++++++++++++++++++++++--
>>  fs/nfs/debugfs.c               | 143
>> +++++++++++++++++++++++++++++++++++++++++
>>  fs/nfs/inode.c                 |   5 ++
>>  fs/nfs/internal.h              |  11 ++++
>>  fs/nfs/nfs3client.c            |   2 +
>>  fs/nfs/nfs4client.c            |   5 ++
>>  fs/nfs/nfs4super.c             |   1 +
>>  fs/nfs/super.c                 |  81 ++++++++++++++++++++---
>>  include/linux/fs.h             |   1 +
>>  include/linux/nfs_fs_sb.h      |   6 ++
>>  include/linux/sunrpc/clnt.h    |   1 +
>>  include/uapi/linux/nfs_mount.h |   1 +
>>  net/sunrpc/clnt.c              |  13 ++--
>>  net/sunrpc/debugfs.c           |   5 ++
>>  net/sunrpc/sched.c             |   3 +
>>  17 files changed, 372 insertions(+), 26 deletions(-)
>>  create mode 100644 fs/nfs/debugfs.c
>>=20
>
> Anyone have any comments on this? Sorry fo the churn, it took a few
> tries to get this to where it would work. I also realize I should have
> put all my RFC patchsets in-reply-to each other instead of starting a
> new thread for each one.

The new semantic for MNT_DETACH|MNT_FORCE is interesting.
As it was never possible before (from /bin/umount), it should be safe to
add a new meaning.
The meaning is effectively "detach the filesystem from the namespace and
detach the transport from the filesystem", which sounds like it is
useful.
It is worth highlighting this, and maybe even cc:ing
linux-api@vger.kernel.org ... done that.

The new umount_end to match umount_begin seems to make sense.  It can
replace a racy semantic with a more predictable one, and that is good.
As you say, we cannot do anything really useful here with remount as
sync can block it by holding ->s_umount.

I'm not sure about the new "transient" option.  It is probably a good
idea but I haven't yet wrapped my mind around exactly what it does so I
don't want to commit just yet.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlonLQEACgkQOeye3VZi
gbmLsw//Zd1FLFG0ypQ47KsEI7TUjoDtdc0663STXVCHfOzhVCBa1ai9YWH+B/3A
O+brR1vYX1rWIvvoRN7UQZzStRjpraSS764NCiyNiI+H/tYAE4BFOwTZOdro6be4
yOqCTQU4G4/mK/7vL5gjSrSQi75yTo3kJqBRCnnGzgsQWWTfuXkY5sJQjRdWf234
wqJvw1eS6Uee2tXwy2q+uIi91oUJW3oALauOgVXRZEcj8D1AwGiLX0+U6/u5nRuU
S4C8c3F1vDlYGYxckNMbgvVLuR0vle6hACpmtnOIdkJQzDjIG82F1K8MqK+HIL5x
xHdMFKmJkz0RRrExZPXWK26hCB1CDA7iah+Hxbk1C40vMSz81GHS2cUkV+y1FIml
CP53ZigVdTggXDss/iDMQL3BwS+aToVw+olqVbsI0gOE0qp8OiXnrhwYWHCinG6U
8+7BM3xqIZ2YHhr5f61PRmzU9zaS5s92lzThD4sRhirRKzOEyFz+dBBrvi5W3FC/
r05/5El0k19FPYP4xUwVasoNlw2ZQD8z6MkBCyMsGfnU7GLGWSBTffVa+evR3XsD
CBXiVbS/t1NZ9dkcRxD6i2wzzO1tsHuZBiSAzWCOUTMi+bohlwHZFLDFPUADpmXT
DvlYJ8muqktuKPYjEZROg6kxXKK7StPCtgVB0SzidKq9GVC1KpM=
=B2LO
-----END PGP SIGNATURE-----
--=-=-=--
