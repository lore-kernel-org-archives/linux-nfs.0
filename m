Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38830 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752001AbdKAXN2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Nov 2017 19:13:28 -0400
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Joshua Watt <jpewhacker@gmail.com>
Date: Thu, 02 Nov 2017 10:13:13 +1100
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: NFS Force Unmounting
In-Reply-To: <1509557061.4755.27.camel@redhat.com>
References: <1508951506.2542.51.camel@gmail.com> <20171030202045.GA6168@fieldses.org> <87h8ugwdev.fsf@notabene.neil.brown.name> <1509557061.4755.27.camel@redhat.com>
Message-ID: <87efphvbhy.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 01 2017, Jeff Layton wrote:

> On Tue, 2017-10-31 at 08:09 +1100, NeilBrown wrote:
>> On Mon, Oct 30 2017, J. Bruce Fields wrote:
>>=20
>> > On Wed, Oct 25, 2017 at 12:11:46PM -0500, Joshua Watt wrote:
>> > > I'm working on a networking embedded system where NFS servers can co=
me
>> > > and go from the network, and I've discovered that the Kernel NFS ser=
ver
>> >=20
>> > For "Kernel NFS server", I think you mean "Kernel NFS client".
>> >=20
>> > > make it difficult to cleanup applications in a timely manner when the
>> > > server disappears (and yes, I am mounting with "soft" and relatively
>> > > short timeouts). I currently have a user space mechanism that can
>> > > quickly detect when the server disappears, and does a umount() with =
the
>> > > MNT_FORCE and MNT_DETACH flags. Using MNT_DETACH prevents new access=
es
>> > > to files on the defunct remote server, and I have traced through the
>> > > code to see that MNT_FORCE does indeed cancel any current RPC tasks
>> > > with -EIO. However, this isn't sufficient for my use case because if=
 a
>> > > user space application isn't currently waiting on an RCP task that g=
ets
>> > > canceled, it will have to timeout again before it detects the
>> > > disconnect. For example, if a simple client is copying a file from t=
he
>> > > NFS server, and happens to not be waiting on the RPC task in the rea=
d()
>> > > call when umount() occurs, it will be none the wiser and loop around=
 to
>> > > call read() again, which must then try the whole NFS timeout + recov=
ery
>> > > before the failure is detected. If a client is more complex and has a
>> > > lot of open file descriptor, it will typical have to wait for each o=
ne
>> > > to timeout, leading to very long delays.
>> > >=20
>> > > The (naive?) solution seems to be to add some flag in either the NFS
>> > > client or the RPC client that gets set in nfs_umount_begin(). This
>> > > would cause all subsequent operations to fail with an error code
>> > > instead of having to be queued as an RPC task and the and then timing
>> > > out. In our example client, the application would then get the -EIO
>> > > immediately on the next (and all subsequent) read() calls.
>> > >=20
>> > > There does seem to be some precedence for doing this (especially with
>> > > network file systems), as both cifs (CifsExiting) and ceph
>> > > (CEPH_MOUNT_SHUTDOWN) appear to implement this behavior (at least fr=
om
>> > > looking at the code. I haven't verified runtime behavior).
>> > >=20
>> > > Are there any pitfalls I'm oversimplifying?
>> >=20
>> > I don't know.
>> >=20
>> > In the hard case I don't think you'd want to do something like
>> > this--applications expect mounts to be stay pinned while they're using
>> > them, not to get -EIO.  In the soft case maybe an exception like this
>> > makes sense.
>>=20
>> Applications also expect to get responses to read() requests, and expect
>> fsync() to complete, but if the servers has melted down, that isn't
>> going to happen.  Sometimes unexpected errors are better than unexpected
>> infinite delays.
>>=20
>> I think we need a reliable way to unmount an NFS filesystem mounted from
>> a non-responsive server.  Maybe that just means fixing all the places
>> where use we use TASK_UNINTERRUTIBLE when waiting for the server.  That
>> would allow processes accessing the filesystem to be killed.  I don't
>> know if that would meet Joshua's needs.
>>=20
>
> I don't quite grok why rpc_kill on all of the RPCs doesn't do the right
> thing here. Are we ending up stuck because dirty pages remain after
> that has gone through?

Simply because the caller might submit a new RPC that could then block.
I've (long ago) had experiences where I had to run "umount -f" several
times before the processes would die and the filesystem could be
unmounted.=20

>
>> Last time this came up, Trond didn't want to make MNT_FORCE too strong as
>> it only makes sense to be forceful on the final unmount, and we cannot
>> know if this is the "final" unmount (no other bind-mounts around) until
>> much later than ->umount_prepare.=20
>
> We can't know for sure that one won't race in while we're tearing things
> down, but do we really care so much? If the mount is stuck enough to
> require MNT_FORCE then it's likely that you'll end up stuck before you
> can do anything on that new bind mount anyway.

I might be happy to wait for 5 seconds, you might be happy to wait for 5
minutes.
So it is fair for me to use MNT_FORCE on a filesystem that both of us
have mounted in different places?

>
> Just to dream here for a minute...
>
> We could do a check for bind-mountedness during umount_begin. If it
> looks like there is one, we do a MNT_DETACH instead. If not, we flag the
> sb in such a way to block (or deny) any new bind mounts until we've had
> a chance to tear down the RPCs.

MNT_DETACH mustn't be used when it isn't requested.
Without MNT_DETACH, umount checks for any open file descriptions
(including executables and cwd etc).  If it finds any, it fails.
With MNT_DETACH that check is skipped.  So they have very different
semantics.

The point of MNT_FORCE (as I understand it), is to release processes
that are blocking in uninterruptible waits so they can respond to
signals (that have already been sent) and can close all fds and die, so
that there will be no more open-file-description on that mount
(different binds mounts have different sets of ofds) so that the
unmount can complete.

If we used TASK_KILLABLE everywhere so that any process blocked in NFS
could be killed, then we could move the handling of MNT_FORCE out of
umount_begin and into nfs_kill_super.... maybe.  Then
MNT_FORCE|MNT_DETACH might be able to make sense.  Maybe the MNT_FORCE
from the last unmount wins?  If it is set, then any dirty pages are
discarded.  If not set, we keep trying to write dirty pages. (though
with current code, dirty pages will stop nfs_kill_super() from even
being called).

For Joshua's use case, he doesn't want to signal those processes but he
presumably trusts them to close file descriptors when they get EIO, and
maybe they never chdir into an NFS filesystem or exec a binary stored there.
So he really does want a persistent "kill all future rpcs".
I don't really think this is an "unmount" function at all.
Maybe it is more like "mount -o remount,soft,timeo=3D1,retrans=3D0"
Except that you cannot change any of those with a remount (and when you
try, mount doesn't tell you it failed, unless you use "-v").
I wonder if it is safe to allow them to change if nosharecache is
given. Or maybe even if it isn't but the nfs_client isn't shared.

>
> I do realize that the mnt table locking is pretty hairy (we'll probably
> need Al Viro's help and support there), but it seems like that's where
> we should be aiming.
>
>>  Maybe umount is the wrong interface.
>> Maybe we should expose "struct nfs_client" (or maybe "struct
>> nfs_server") objects via sysfs so they can be marked "dead" (or similar)
>> meaning that all IO should fail.
>>=20
>
> Now that I've thought about it more, I rather like using umount with
> MNT_FORCE for this, really. It seems like that's what its intended use
> was, and the fact that it doesn't quite work that way has always been a
> point of confusion for users. It'd be nice if that magically started
> working more like they expect.

So what, exactly, would you suggest be the semantics of MNT_FORCE?
How does it interact with MNT_DETACH?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAln6VQsACgkQOeye3VZi
gbmqTg//dp3V8R62aJNtht0qJz/vjqq11lH4ILB2sJlWmZyF2wPUpxF4gK1qs/Tq
vAqxZeSkvuQoUlHE6BCwCWbp0TsUGVZ9Pe89P3FC1TEp03LOKd2e2WmA0jkgDTyw
d2fbZiw9+RLeyMSA0wApHeLiLne/VrUwTtnbj2vgQovWKpgLXdO6YAC4tLsb4zgW
pP6VX3KBJqCkp+LgPRPfJHrg6XD/w8cf+I72x5cEwil9rgmR4tVK7RJKyirHpZR8
uw9uf+4i7QvO98pDrtzcCAK7GnOxfdvdGYLVsPExKeArRz0x/lJ5jfpGlCOYSNo5
8mBm+rBqbGADTgan8wZv3RAZyjuolIyzj+GnIlz91jtPbwqZV3Xt4Ek35MRB5klB
zCe7VmIC9N97CuGHZV0flMZefq2KNtTlzFE1iwf+2JFDbMPFAsaAleEap3dskGo4
PInotnaSHQ+BjM8/ZFG3wNMDWWrRYC8bm/CyTPJaHhzvZgPvm9AjDt5LHGT8VWtu
M4bq+GbrFdA/DvBBenzK20ZZY/H9HHPwCpFiWrNwgaG7ONASgZqDTCNjPb4s2MJZ
HCMKHZDLh+lzHpXIR5QY+rjFl16Pue2ppioDw8uFf/5rian2qtsN6BlebrRL3Kpb
WF/0gTcpbWfOCqej05Etfd7ysifdQBgS+dFzVPHr5QD+kzSQGa4=
=AoNV
-----END PGP SIGNATURE-----
--=-=-=--
