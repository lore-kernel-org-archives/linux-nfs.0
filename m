Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48946 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751546AbdJ3VJx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Oct 2017 17:09:53 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Joshua Watt <jpewhacker@gmail.com>
Date: Tue, 31 Oct 2017 08:09:44 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS Force Unmounting
In-Reply-To: <20171030202045.GA6168@fieldses.org>
References: <1508951506.2542.51.camel@gmail.com> <20171030202045.GA6168@fieldses.org>
Message-ID: <87h8ugwdev.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 30 2017, J. Bruce Fields wrote:

> On Wed, Oct 25, 2017 at 12:11:46PM -0500, Joshua Watt wrote:
>> I'm working on a networking embedded system where NFS servers can come
>> and go from the network, and I've discovered that the Kernel NFS server
>
> For "Kernel NFS server", I think you mean "Kernel NFS client".
>
>> make it difficult to cleanup applications in a timely manner when the
>> server disappears (and yes, I am mounting with "soft" and relatively
>> short timeouts). I currently have a user space mechanism that can
>> quickly detect when the server disappears, and does a umount() with the
>> MNT_FORCE and MNT_DETACH flags. Using MNT_DETACH prevents new accesses
>> to files on the defunct remote server, and I have traced through the
>> code to see that MNT_FORCE does indeed cancel any current RPC tasks
>> with -EIO. However, this isn't sufficient for my use case because if a
>> user space application isn't currently waiting on an RCP task that gets
>> canceled, it will have to timeout again before it detects the
>> disconnect. For example, if a simple client is copying a file from the
>> NFS server, and happens to not be waiting on the RPC task in the read()
>> call when umount() occurs, it will be none the wiser and loop around to
>> call read() again, which must then try the whole NFS timeout + recovery
>> before the failure is detected. If a client is more complex and has a
>> lot of open file descriptor, it will typical have to wait for each one
>> to timeout, leading to very long delays.
>>=20
>> The (naive?) solution seems to be to add some flag in either the NFS
>> client or the RPC client that gets set in nfs_umount_begin(). This
>> would cause all subsequent operations to fail with an error code
>> instead of having to be queued as an RPC task and the and then timing
>> out. In our example client, the application would then get the -EIO
>> immediately on the next (and all subsequent) read() calls.
>>=20
>> There does seem to be some precedence for doing this (especially with
>> network file systems), as both cifs (CifsExiting) and ceph
>> (CEPH_MOUNT_SHUTDOWN) appear to implement this behavior (at least from
>> looking at the code. I haven't verified runtime behavior).
>>=20
>> Are there any pitfalls I'm oversimplifying?
>
> I don't know.
>
> In the hard case I don't think you'd want to do something like
> this--applications expect mounts to be stay pinned while they're using
> them, not to get -EIO.  In the soft case maybe an exception like this
> makes sense.

Applications also expect to get responses to read() requests, and expect
fsync() to complete, but if the servers has melted down, that isn't
going to happen.  Sometimes unexpected errors are better than unexpected
infinite delays.

I think we need a reliable way to unmount an NFS filesystem mounted from
a non-responsive server.  Maybe that just means fixing all the places
where use we use TASK_UNINTERRUTIBLE when waiting for the server.  That
would allow processes accessing the filesystem to be killed.  I don't
know if that would meet Joshua's needs.

Last time this came up, Trond didn't want to make MNT_FORCE too strong as
it only makes sense to be forceful on the final unmount, and we cannot
know if this is the "final" unmount (no other bind-mounts around) until
much later than ->umount_prepare.  Maybe umount is the wrong interface.
Maybe we should expose "struct nfs_client" (or maybe "struct
nfs_server") objects via sysfs so they can be marked "dead" (or similar)
meaning that all IO should fail.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAln3lRoACgkQOeye3VZi
gblc4RAAsSnwpzlcfAbmt7yNdcffa5PNmTBv/O+wrUU9irhqWynfpictdcwf58Ca
HYF1pBVKG2zEL631hZZAh+KJcfh0Bxb6pdx+6rOyIlINFCNGPnX5to+U+ADIkbVc
3oJwgv8CSaJwoA3mSC92wgyr5G1II2BshhhFMUvaOUFr1i71o+NgSIWyVzkVdqdX
tabk5nsaLrpvuThmWcTh0eW0NsQgWMc7sNlCiRp8yzXyMmXAkwAhHviJah4luTH2
JCElSuj57kj/QkUr3VVbpI2X7+Id82mPxOuUmvozp7kp4J4WTOcOZ37XoxQn5QVy
7H8/xDHNc3WnBOgqCL/wRutsvQ0J4eZflZCSkXKoZB0UOiurDeAGcXoPIvCBBaXv
YofxoiZi+RQ0J3OTrhjxU/2C7b4Xci5c1fSXskAeXqZS2ANKy+exynjnHtRyaQah
ok8BZmGXm+u9zImp/maLZOddX1hamjtRrZN+Nfjw7+VOaOxYIRDo+t6sspUr7zOZ
PwC38l+x3pw8xqpexshoHpLvbZPfWMs94JtsSaxK2qXB90nRjzYj3suotvrs7lNF
ZPnxwYfumz4cc+ZKrrpw1JUnRL0aD+3KPoKZhJMGIgkspK4dJfHGn26VESRRBAgc
k0pYRwVa5wpumgyjuubyWP7UuP6ot3wEJRvXRzEnQzpK90dZKHU=
=/hNt
-----END PGP SIGNATURE-----
--=-=-=--
