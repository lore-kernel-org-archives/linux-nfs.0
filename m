Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42197 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031672AbbJ3WqS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Oct 2015 18:46:18 -0400
From: Neil Brown <neilb@suse.com>
To: Karel Zak <kzak@redhat.com>
Date: Sat, 31 Oct 2015 09:46:10 +1100
Cc: util-linux@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: mount does not accurately identify existing NFS mounts, and shouldn't try.
In-Reply-To: <20151030105509.GG19508@ws.net.home>
References: <87twpnll5y.fsf@notabene.neil.brown.name> <20151030105509.GG19508@ws.net.home>
Message-ID: <871tccvutp.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 30 2015, Karel Zak wrote:

> On Mon, Oct 19, 2015 at 12:08:41PM +1100, Neil Brown wrote:
>> 	/* Refuse the same filesystem on the same mount point */
>> 	err =3D -EBUSY;
>> 	if (path->mnt->mnt_sb =3D=3D newmnt->mnt.mnt_sb &&
>> 	    path->mnt->mnt_root =3D=3D path->dentry)
>> 		goto unlock;
>>=20
>> This is the *only* time that the kernel returns EBUSY for a "mount a new
>> filesystem" request (remount can return EBUSY for other reasons I
>> think).
>>=20
>> So in the case where "mount" thinks it should check if the filesystem is
>> already mounted and ignore the request if it is, the best thing it can
>> do is to just try the mount and ignore any "EBUSY" error status - treat
>> that the same as success.
>>=20
>> So all that code for "is this the same mountpoint" can probably be
>> discarded.
>
> Well, we have many situations (another than mount -a) when you want to
> know if the FS is mounted, but you have not permissions for mount(2)
> or you don't want to try it (because mount(2) may trigger many another
> things in userspace).
>
>> Did I miss any important consideration there?
>
> The problem is that the way between fstab entry and mount(2) is
> sometimes pretty complex (mount.<type> helpers, loop devices,
> UUID/LABEL translation, etc).
>
> So, compare fstab with /proc/mounts is usually good compromise...
>
> Your suggestion seems usable for mount -a, but it's one small use-case
> (and for example systemd don't use "mount -a" during boot).
>
>> Unfortunately this change could be awkward to implement as /sbin/mount
>> decides whether to try the mount and (for NFS), /sbin/mount.nfs gives an
>> error message if EBUSY is returned.  Would we need to pass a "noebusy"
>> flag, but only if mount.nfs were willing to accept it....
>>=20
>> Any suggestions?
>
> We have kill(PID, 0) to detect if the PID is valid, you don't have to
> parse all /proc. It would be nice to have the same for filesystems,
> something like
>
>     mount("/dev/sda1, "/mnt", "ext4", MS_NOMOUNT, NULL)

I like that!  I really do.  It returns the same error as mount would if
run by a privileged uses, or returns success without actually changing
anything.
MS_NOMOUNT is incompatible with MS_REMOUNT, MS_MOVE and several others.

I won't be providing a kernel patch straight away, but I would like to
see this happen.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWM/MyAAoJEDnsnt1WYoG57N8QAIhTN3k3rNznyVETOU1/MKef
iUFAjXd0T3GRuZlFBm3h+8sY6YPD0XOOSJsUtsWtGEZ3CyGXINtIwuZ1DyeukTvR
waY12fV77LPpev/8mjfIp5ZQ4D4sMoxDFVFYgpw+dfT4FU6Us0teo9B+UOqVVfY0
hfRUm3jMEPberBL6VaCVb8OwXro03Z6X5aI6iNAEcM//hxxXpG1wKZ0MGuhmSghN
MWwI1w8JCCU47W6MDB1U2pm4XjtHNRUiv7xHNBX3xlRwwyP2mBJi1lO4B5MyJJuY
Kgka6sL/PiGSHi47psyVYGkrJ8HFg5CI73NNR1rW/A4Lct5ksJCnXHGJhhChU9Vq
KETlld3XD5UEyTMy+26OYuEeGTmQF8eKnC5H1eW4KuRCvFq046I98gfhpnVoMMlY
IijvKeM09hClMXaMWqTHgOTk78Cj3/z4RGn8OpgfauOQlwoEaDXJH8qIObJNi/EI
jmmMUPfVs614cK8KwpsBw8daPBejJrHkSKTuwqdZ+jtdjrCCx8/nAHzgK9jeIyfb
tY/S8C1WETO+6Tmy+b+aGm0O0NjH9s0TExrSpPq8Ti2rs8adzW2wcBC2dv9YBEma
QGKKacHSDpXLCpfpbNTkOz5L3sWglGWEOVQNEjqtRhWVb86zYFd7Fq4FPiX35M/d
yl5XGzv9JysYsvt7XyAp
=nwYz
-----END PGP SIGNATURE-----
--=-=-=--
