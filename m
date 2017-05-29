Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53364 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751083AbdE2WGI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 29 May 2017 18:06:08 -0400
From: NeilBrown <neilb@suse.com>
To: Lennart Poettering <lennart@poettering.net>
Date: Tue, 30 May 2017 08:05:57 +1000
Cc: systemd-devel@freedesktop.org, linux-nfs@vger.kernel.org
Subject: Re: [systemd-devel] systemd and NFS "bg" mounts.
In-Reply-To: <20170529133814.GC17967@gardel-login>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name> <20170529133814.GC17967@gardel-login>
Message-ID: <87wp8zfhdm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, May 29 2017, Lennart Poettering wrote:

> On Fri, 26.05.17 12:46, NeilBrown (neilb@suse.com) wrote:
>
>>=20
>> Hi all,
>>  it appears that systemd doesn't play well with NFS "bg" mounts.
>>  I can see a few options for how to address this and wonder if anyone
>>  has any opinions.
>
> Yeah, this has come up before. Long story short: "bg" is simply not
> compatible with systemd. We assume that the /bin/mount's effect is
> visible in /proc/self/mountinfo, and everything else is considered a
> bug, i.e. /bin/mount lying to us. And I think that's a pretty rational
> assumption and requirement to make.
>
> I am not particularly convinced the "bg" usecase is really such a
> great idea, since it is necessarily racy: you never know whether mount
> is actually in effect or not, even though /bin/mount claims so. I am
> pretty sure other options (such as autofs mounts, which are dead-easy
> to use in system: just replace the "bg" mount option in fstab by
> "x-systemd.automount") are much better approaches to the problem at
> hand: they also make your local system less dependent on remote
> network access, but they do give proper guarantees about their
> runtime: when the autofs mount is established the path is available.
>
> Hence I am tempted to treat the issue as a documentation and warning
> issue: accept that "bg" is not supported, but document this better. In
> addition, we should probably log about "bg" being broken in the
> fstab-generator. I file a bug about that now:
>
> https://github.com/systemd/systemd/issues/6046

There is a weird distorted sort of justice here.  When NFS first
appeared, it broke various long-standing Unix practices, such as
O_EXCL|O_CREAT for lock files.  Now systemd appears and breaks a
long-standing NFS practice: bg mounts.

I hoped we could find a way to make them work, but I won't cry over
their demise.  I much prefer automount .... I think all NFS mounts
should be automounts.

I see this is already documented in systemd.mount:

  The NFS mount option bg for NFS background mounts as documented in nfs(5)=
 is
  not supported in /etc/fstab entries.

I wonder how many people actually read that.
We should probably add symmetric documentation to nfs(5)
Both should give clear pointers to x-systemd.automount.


>
>>  This is better, but the background mount.nfs can persist for a long
>>  time.  I don't think it persists forever, but at least half an hour I
>>  think.
>>=20
>>  When the foo.mount unit is stopped, the mount.nfs process isn't
>>  killed.
>
> Hmm, if you see this, then this would be a bug: mount units that are
> stopped should not leave processes around.
>
>>  I don't think this is a major problem, but it is unfortunate and could
>>  be confusing.  During testing I've had multiple mount.nfs background
>>  processes all attached to the one .mount unit.
>
> Humpf, could you file a bug?

https://github.com/systemd/systemd/issues/6048

>
> While I think the "bg" concept is broken, as discussed above, having
> FUSE mounts with processes in the background is actually supported,
> and we should clean them up properly when the mount unit is stopped.
>
> Hmm, maybe mount.nfs isn't properly killable? i.e. systemd tries to
> kill it, but it refuses to be killed?

mount.nfs responds cleanly to SIGTERM.

>
>>  What should we do about bg NFS mounts with systemd?
>>  Some options:
>>    - declare "bg" to be not-supported.  If you don't need the filesystem
>>      to be present for boot, then use x-systemd.automount, or some other
>>      automount scheme.
>>      If we did this, we probably need to make it very obvious that "bg"
>>      mounts aren't supported - maybe a log message that appears when
>>      you do "systemctl status ..." ??
>
> I am all for this, as suggested above. I'd only log from
> fstab-generator though. (That said, if we want something stronger, we
> could also add the fact that we stripped "bg" from the mount optoins
> to the DEscription=3D of the generated mount unit.)

That last bit sounds like a very good idea.  Stripping "bg" could be seen
as a "surprising" thing for fstab-generator to do.  Making it as obvious
as possible to the sys-admin would be a good thing (and would probably
make support personnel happy too).

>
>>    - decide that "bg" is really just a lame attempt at automounting, and
>>      that now we have real automounting, "bg" can be translated to that.
>>      So systemd-fstab-generator would treat "bg" like
>>      "x-systemd.automount" and otherwise strip it  from the list of
>>      options.
>
> I am a bit afraid of this I must say. The semantics are different
> enough to likely cause more problems then we'd solve with this. Not
> supporting this at all sounds like the much better approach here:
> let's strip "bg" when specified.
>
>>    - do our best to really support "bg".  That means, at least, applying
>>      a much larger timeout to "bg" mounts, and preferably killing any
>>      background processes when a mount unit is stopped.  Below is a
>>      little patch which does this last bit, but I'm not sure it is gener=
ally
>>      safe.
>
> As mentioned I think this would just trade one race for a couple of
> new ones, and that appears to be a bad idea to me.
>
>>  A side question is: should this knowledge about NFS be encoded in
>>  systemd, or should nfs-utils add the necessary knowledge?
>
> I am pretty sure we should keep special understanding of NFS at a
> minimum in PID 1, but I think we can be less strict in
> fstab-generator, as its primary job is compat with UNIX anyway.

I was thinking about which source package the knowledge would be in, and
hence which set of maintainers would over-see it.  I don't expect
systemd maintainers to be fully in-touch with the details of NFS, but
then NFS developers cannot be fully in-touch with how systemd works.

Apart from some documentation changes, we probably don't need to put
anything new in nfs-utils at the moment.

>
>>=20
>>  i.e. we could add an nfs-fstab-generator to nfs-utils which creates
>>  drop-ins to modify the behaviour of the drop-ins provided by
>>  systemd-fstab-generator.
>>  Adding the TimeoutSec=3D would be easy.  Stripping the "bg" would be
>>  possible.
>>  Changing the remote-fs.target.requires/foo.mount symlink to be
>>  remote-fs.target.requires/foo.automount would be problematic
>>  though.
>
> Well, I'd be fine with letting NFS do its own handling of the NFS
> /etc/fstab entries, but I think the special casing of "bg" is fine to
> simply add to the existing generator in systemd.
>
>>  Could we teach systemd-fstab-generator to ignore $TYPE filesystems
>>  if TYPE-fstab-generator existed?
>
> Well, generators can override each other in very limited ways (as
> there are three different output directories a gnerator can write to,
> which are inserted at different places in the unit file search path),
> we could build on that. That said, I think adding this to
> fstab-generator in systemd is OK.

Ahh, of course.  That is what normal-dir / early-dir / late-dir is for.
I'll keep that in mind in case I do ever need it.

>
>>  Or should we just build all this filesystem-specific knowledge into
>>  systemd?
>
> For now, I think adding this to systemd's fstab-generator would be fine.
>
> Hope this makes sense,

Yes it does.  It wasn't the outcome I was hoping for, but it is hard to
argue against it.

Thanks a lot,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlksm0YACgkQOeye3VZi
gblxyg//aXhXokRed7nWXCXUwJtK0lCjLrNTNMHfjLmwzgc+QlBF6medoxs0ko+v
9eR9LFF4x2hecmdKTW2YU9bLhHMSlVXGD7VrCEEizoZ4QAb8OXAlJiafRobnfiBN
JV9QlLb+083VMH93DA2V57eddYLnavV086WY2epmc8SThxdQxk25DE1kFH7Qcodo
Pd1mjphBzToiVBjIfIwm6uI7uRwy144AZDE2HdVeuik16BkXdS0vTEs6IB3G3p/H
U7CbglbBfD6rWavz3ksgO1MRRL2Ne7HyUo2B2G6uHofu7BTyThqs6TYuqCQSPDPp
SnpU5ZjLsQFDEFuUuCZ/95Es9iJBRbMOHTwZzJXHLT6jeffw4iy6gDYWJiCbkLer
ZfHauc8fuXAiuILgcEUXTjACIE6NVMT3fhkVtpjpDET29P/hmivLlcNCz4sfIABl
+L/2s00G3/kcT6IJv3uE5iOcsYtGpeV/q0RO4G3GTzvyJ7plrK3WDxpQI9eK7mfu
+orCFY8XEIieWedccQozpZH4Qybb8Y5ogCcns1zDvKSZd+GDOpvA7WsnQVqMzW7m
45hSlWNpwz17JjscGF8dFCgTyT7vtC4Vrr6ObRbfwhdS87Kj34yd72eSNlLYhwsG
rd7ifIEUo9h9UVfnlvc2bbuVVgzFfkCHNQ0oSnVkA4ImeoPbkPw=
=swbK
-----END PGP SIGNATURE-----
--=-=-=--
