Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34082 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752936AbcHRBdC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Aug 2016 21:33:02 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 18 Aug 2016 11:32:52 +1000
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/8] mountd: remove 'dev_missing' checks
In-Reply-To: <20160816152148.GC30124@fieldses.org>
References: <20160714021310.5874.22953.stgit@noble> <20160714022643.5874.84409.stgit@noble> <20160718200121.GC12304@fieldses.org> <878twx9ra3.fsf@notabene.neil.brown.name> <20160721172452.GC27148@fieldses.org> <87wpjokofy.fsf@notabene.neil.brown.name> <20160816152148.GC30124@fieldses.org>
Message-ID: <87bn0qj1yz.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 17 2016, J. Bruce Fields wrote:
>
>> It turns out the the customer is NFS-exporting a filesystem mounted
>> using iSCSI.  Such filesystems are treated by systemd as "network"
>> filesystem, which seems at least a little bit reasonable.
>> So it is "remote-fs" that applies, or more accurately
>> "remote-fs-pre.target"
>> And nfs-server.services contains:
>>=20
>> Before=3Dremote-fs-pre.target
>
> This is to handle the loopback case?

That is what the git-commit says.  Specifically to handle the
shutdown/unmount side.

>
> In which case what it really wants to say is "before nfs mounts" (or
> even "before nfs mounts of localhost"; and vice versa on shutdown).  I
> can't tell if there's an easy way to get say that.

I'd be happy with a difficult/complex way, if it was reliable.
Could we write a systemd generator which parses /etc/fstab, determines
all mount points which a loop-back NFS mounts (or even just any NFS
mounts) and creates a drop-in for nfs-server which adds
  Before=3Dmount-point.mount
for each /mount/point.

Could that be reliable?  I might try.


Another generator could process /etc/exports and add
   RequiresMountsFor=3D/export/point
for every export point.  Maybe skip export points with the "mountpoint"
option as mountd expects those to possibly appear later.
=20=20=20
>
>> So nfsd is likely to start up before the iSCSI filesystems are mounted.
>>=20
>> The customer tried to stop this bt using a systemd drop-in to add
>> RequiresMountsFor=3D for the remote filesystem, but that causes
>> a loop with the Before=3Dremote-fs-pre.target.
>>=20
>> I don't think we need this line for sequencing start-up, but it does
>> seem to be useful for sequencing shutdown - so that nfs-server is
>> stopped after remote-fs-pre, which is stopped after things are
>> unmounted.
>> "useful", but not "right".  This doesn't stop remote servers from
>> shutting down in the wrong order.
>> We should probably remove this line and teach systemd to use "umount -f"
>> which doesn't block when the server is down.  If systemd just used a
>> script, that would be easy....
>>=20
>> I'm not 100% certain that "umount -f" is correct.  We just want to stop
>> umount from stating the mountpoint, we don't need to send MNT_FORCE.
>> I sometimes think it would be really nice if NFS didn't block a
>> 'getattr' request of the mountpoint.  That would remove some pain from
>> unmount and other places where the server was down, but probably would
>> cause other problem.
>
> I thought I remembered Jeff Layton doing some work to remove the need to
> revalidate the mountpoint on unmount in recent kernels.

Jeff's work means that the umount systemcall won't revalidate the mount
point.  This is important and useful, but not sufficient.
/usr/bin/mount will 'lstat' the mountpoint (unless -f or -l is given).
That is what causes the problem.
mount mostly want to make sure it has a canonical name.  It should be
possible to get it to avoid the stat if the name can be determined to
be canonical some other way.  Just looking to see if it is in
/proc/mounts would work, but there are comments in the code about
/proc/mounts sometimes being very large, and not wanting to do that too
much.... need to look again.

>
> Is that the only risk, though?  Maybe so--presumably you've killed any
> users, so any write data associated with opens should be flushed.  And
> if you do a sync after that you take care of write delegations too.

In the easily reproducible case, all user processes are gone.
It would be worth checking what happens if processes are accessing a
filesystem from an unreachable server at shutdown.
"kill -9" should get rid of them all now, so it might be OK.
"sync" would hang though.  I'd be happy for that to cause a delay of a
minute or so, but hopefully systemd would (or could be told to) kill -9
a sync if it took too long.

>
>> Does anyone have any opinions on the best way to make sure systemd
>> doesn't hang when it tries to umount a filesystem from an unresponsive
>> server?  Is "-f" best, or something else.
>>=20
>>=20
>>=20
>> There is another issue related to this that I've been meaning to
>> mention.  It related to the start-up ordering rather than shut down.
>>=20
>> When you try to mount an NFS filesystem and the server isn't responding,
>> mount.nfs retries for a little while and then - if "bg" is given - it
>> forks and retries a bit longer.
>> While it keeps gets failures that appear temporary, like ECONNREFUSED or
>> ETIMEDOUT (see nfs_is_permanent_error()) it keeps retrying.
>>=20
>> There is typically a window between when rpcbind starts responding to
>> queries, and when nfsd has registered with it.  If mount.nfs sends an
>> rpcbind query in this window. It gets RPC_PROGNOTREGISTERED which
>> nfs_rewrite_pmap_mount_options maps to EOPNOTSUPP, and
>> nfs_is_permanent_error() thinks that is a permanent error.
>
> Looking at rpcbind(8)....  Shouldn't "-w" prevent this by loading some
> registrations before it starts responding to requests?

"-w" (which isn't listed in the SYNOPSIS!) only applies to a warm-start
where the daemons which previously registered are still running.
The problem case is that the daemons haven't registered yet (so we don't
necessarily know what port number they will get).

To address the issue in rpcbind, we would need a flag to say "don't
respond to lookup requests, just accept registrations", then when all
registrations are complete, send some message to rpcbind to say "OK,
respond to lookups now".  That could even be done by killing and
restarting with "-w", though that it a bit ugly.

I'm leaning towards having mount retry after RPC_PROGNOTREGISTERED for
fg like it does with bg.

Thanks,
NeilBrown


>
> --b.
>
>>=20
>> Strangely, when the 'bg' option is used, there is special-case code
>> Commit: bf66c9facb8e ("mounts.nfs: v2 and v3 background mounts should re=
try when server is down.")
>> to stop EOPNOTSUPP from being a permanent error.
>>=20
>> Do people think it would be reasonable to make it a transient error for
>> foreground mounts too?
>>=20
>> Thanks,
>> NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXtRBEAAoJEDnsnt1WYoG5bXoP/0kfp3HBRtVtdOrKcHxpIRZl
D1xyiCZkGinoseYnkkUNnBApPPtL/bC9owSxgOwF4IJ7XykBu//Ube4SexxFUHYx
z5RJ1JvFbXnLk4Z4oB4bo4bwwEo+N9Wa6IDYMNCcAtLNBuX8r3T9TIf6vU2MagIb
4o9iEB5OvEiCx1G7GXnyp5/IgeTC9Toc6J0LavYLkKldNyXlq69umea3CoxlsQoi
LiYRby95UpNMj2An79flGwP0vei1uTezTETUAkVIJr/aAaB27eCbGU0fees3SZw3
vHizGQkpShFObqoqKppeSxIyzD4KXPs24bJQ9ATMk/hU9/zR5PmH/xnep2xQXMbb
R3rF6jVZeA1DGJcUD0Y9NCPnW5HU6ueIdKgFauqQDlIH7BcAiTO+w+kinieAucYo
c/SXDGdlnfAclQ5E+RKAWtS5Z11yMxvQPBxO8y0S4ZFylsgleX6WB02Ahk6lYOdK
3kijck24SMlwLJhzD+HW2QmPPVRC794fr5piM0BhDn2NA1IJ9wxOxtlTb7syeSIc
+GksTuFNESuM/yXefgrg+9bNPRQmsYqjmXEAwhqqxZr6Zh8WQ8cFSqTT4T7dy3VM
NRiorpREyE6eWn5ulde+uDMJ2sE03DXnPURKS2SrLSeNkwt72i+EjVgN2UtcMid1
os423/pKxypyELf0NLNy
=T8sc
-----END PGP SIGNATURE-----
--=-=-=--
