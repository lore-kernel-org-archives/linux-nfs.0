Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43511 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750764AbdKAAx1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Oct 2017 20:53:27 -0400
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Joshua Watt <jpewhacker@gmail.com>
Date: Wed, 01 Nov 2017 11:53:18 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS Force Unmounting
In-Reply-To: <1509460909.4553.37.camel@kernel.org>
References: <1508951506.2542.51.camel@gmail.com> <20171030202045.GA6168@fieldses.org> <87h8ugwdev.fsf@notabene.neil.brown.name> <1509460909.4553.37.camel@kernel.org>
Message-ID: <8760aux1j5.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 31 2017, Jeff Layton wrote:

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
>> Last time this came up, Trond didn't want to make MNT_FORCE too strong as
>> it only makes sense to be forceful on the final unmount, and we cannot
>> know if this is the "final" unmount (no other bind-mounts around) until
>> much later than ->umount_prepare.  Maybe umount is the wrong interface.
>> Maybe we should expose "struct nfs_client" (or maybe "struct
>> nfs_server") objects via sysfs so they can be marked "dead" (or similar)
>> meaning that all IO should fail.
>>=20
>
> I like this idea.
>
> Note that we already have some per-rpc_xprt / per-rpc_clnt info in
> debugfs sunrpc dir. We could make some writable files in there, to allow
> you to kill off individual RPCs or maybe mark a whole clnt and/or xprt
> dead in some fashion.
>
> I don't really have a good feel for what this interface should look like
> yet. debugfs is attractive here, as it's supposedly not part of the
> kernel ABI guarantee. That allows us to do some experimentation in this
> area, without making too big an initial commitment.

debugfs might be attractive to kernel developers: "all care but not
responsibility", but not so much to application developers (though I do
realize that your approch was "something to experiment with" so maybe
that doesn't matter).

My particular focus is to make systemd shutdown completely reliable.  It
should not block indefinitely on any condition, including inaccessible
servers and broken networks.

In stark contrast to Chuck's suggestion that


   Any RPC that might alter cached data/metadata is not, but others
   would be safe.

("safe" here meaning "safe to kill the RPC"), I think that everything
can and should be killed.  Maybe the first step is to purge any dirty
pages from the cache.
=2D the server is up, we write the data
=2D if we are happy to wait, we wait
=2D otherwise (the case I'm interested in), we just destroy anything
  that gets in the way of unmounting the filesystem.

I'd also like to make the interface completely generic.  I'd rather
systemd didn't need to know any specific details about nfs (it already
does to some extend - it knows it is a "remote" filesystem) but
I'd rather not require more.

Maybe I could just sweep the problem under the carpet and use lazy
unmounts.  That hides some of the problem, but doesn't stop sync(2) from
blocking indefinitely.  And once you have done the lazy unmount, there
is no longer any opportunity to use MNT_FORCE.

Another way to think about this is to consider the bdi rather than the
mount point.  If the NFS server is never coming back, then the "backing
device" is broken.  If /sys/class/bdi/* contained suitable information
to identify the right backing device, and had some way to "terminate
with extreme prejudice", then and admin process (like systemd or
anything else) could choose to terminate a bdi that was not working
properly.

We would need quite a bit of integration so that this "terminate"
command would take effect, cause various syscalls to return EIO, purge
dirty memory, avoid stalling sync().  But it hopefully it would be
a well defined interface and a good starting point.

If the bdi provided more information and more control, it would be a lot
safer to use lazy unmounts, as we could then work with the filesystem
even after it had been unmounted.

Maybe I'll trying playing with bdis in my spare time (if I ever find out
what "spare time" is).

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAln5Gv8ACgkQOeye3VZi
gbmbkw//UgRhZQGXuHoeI1UNGwXKkH4/Ki8J/Q1CtyYG2YBAxUl1hADK8j03btX4
CIT/0Jlc1OERuAR8ovTRoZSuibOtPQalQ5CuMW3mlGF7idVcMKfgL6FT0iCAQhA1
hOw5LFOx3W9iMkKfXsc8Kk6dfWTY/1CTp5e19JIK4YgVn7rEn5afyOUqM5Djx6f8
pZFoVbwd1cljEGhCSH5Al2FSrSPBjCzqsfTDteXMt0YgDi3Olb9HXlCb0rSBZXyh
6ahOfD5Ppy/DbFXuJy1e5mdgWHv95WqNlf5ilgyAMU/wLtXc7PjcL/TuJ4RN+Zdh
WsvmxSxKmxuiK+ZvcvlgffQSUTCofp6HwSTPdK95HXZiYCdeyTVjAjUWRaTAquiW
kgcanqPV/JZg0wkmJCk6aRDxL9M1a2FZZc8988z6HiH50tYK1uxnVRJELoMkKnY8
ZtUofyQlMsFQhl4q21TQuUMt3lN3nCtt1UTyEGX99PfJsNrYqmSlogvo/72MJECn
91HdOcJoynVI3o9yp5oWmIYATvLxpc05XZEdwSTi6eIdavxgsA+RRvhtwLouJeGV
avSJTnw/Cax02yXZ2IqSaCQ63IuMqy7aYLwoQBJ963z5jxaglTer8Z9SawrZIsJX
hWUp1X0F9mv2VC+U5cioUq9nMxyO0jnnPCUywZittURjWcKW1yg=
=Xd1b
-----END PGP SIGNATURE-----
--=-=-=--
