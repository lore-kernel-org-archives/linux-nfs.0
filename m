Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50271 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932739AbcKJWfp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Nov 2016 17:35:45 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 11 Nov 2016 09:35:38 +1100
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Question about nfsdcltrack --storagedir
In-Reply-To: <20161110163553.GA16125@fieldses.org>
References: <87k2cdmi26.fsf@notabene.neil.brown.name> <1478692626.2394.9.camel@redhat.com> <877f8c9pku.fsf@notabene.neil.brown.name> <20161110163553.GA16125@fieldses.org>
Message-ID: <87lgwrklol.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 11 2016, J. Bruce Fields wrote:

> On Thu, Nov 10, 2016 at 10:54:41AM +1100, NeilBrown wrote:
>> On Wed, Nov 09 2016, Jeff Layton wrote:
>>=20
>> > On Wed, 2016-11-09 at 14:46 +1100, NeilBrown wrote:
>> >> Hi,
>> >>  I notice that nfsdcltrack has a "--storagedir" option.
>> >>  I wonder how this can be used, given the nfsdcltrack is only(?) call=
ed
>> >>  from the kernel and there is no(?) mechanism to pass extra options.
>> >>=20
>> >>  In a clustered-server context it would make sense(?) to share the
>> >>  database between cluster nodes and it is easiest to do this if the
>> >>  file in a separate filesystem (mounted as part of fail-over) rather
>> >>  than in /var.
>> >>  This can(?) be achieved using a symlink, but rpm likes to remove
>> >>  symlinks to non-existent locations.
>> >>=20
>> >>  With NFSv3 the equivalent is the state files maintained by statd, and
>> >>  these can be relocated by passing the -P option to rpc.statd.
>> >>  How does one do a similar thing for NFSv4???
>> >>=20
>> >>=20
>> >
>> > Ahh, I added that option mostly for when I was testing it. I did a lot
>> > of the earlier testing running it by hand, and --storagedir let me use=
 a
>> > different directory for the db. I did have a vague idea that we might
>> > use it in the situation you describe, but I never wired that up as I
>> > didn't have a real need for it.
>> >
>> > We could add a new module parm that would set that option when the
>> > kernel does its callout, or allow passing the storagedir by environment
>> > variable.
>> >
>> > What would make the most sense from a usability standpoint?
>>=20
>> Maybe a config file in /etc/ which nfsdcltrack reads on start-up?
>> Though in some ways I'd rather that instead of running a program, the
>> kernel sent a message to user-space.  Possibly a u-event?
>> Then existing configuration mechanisms could be used to choose a program
>> and a context for it to run in.
>> I wonder if u-events handle namespaces at all.
>>=20
>> This came up because a customer was symlinking all of /var/lib/nfs to
>> shared storage (and lost their symlink thanks to rpm).  That isn't a
>> solution that I really like, and it led me to reflect on other things in
>> /var/lib/nfs.
>>=20
>> etab - holds a normalized copy of /etc/exports, plus ad hoc changes.
>>        It would like in /run/nfs if we built this today
>> export-lock - lockfile to protect changes to above. Would also be
>>        in /run if we built it today. (I wonder why that doesn't
>>        use .etab.lock, which is already used for locking)
>> state, sm, sm.bak - statd state files.  These belong in /var/lib/nfs
>>        but are easily relocated with args to rpc.statd and sm-notify.
>> v4recovery - the NFSv4 version of above
>> xtab - this hasn't been needed since we gained /proc/fs/nfs/exports
>>        It is just a record of what should be in the kernel
>>        We should remove this.  I'll make a patch.
>> rmtab - this hasn't been needed since the "new cache" and the
>>        up-call mechanism were created.  It might be still used
>>        to respond to "showmount" commands, but that was never reliable.
>>        If we keep it, it should probably move to /run.
>>        But what do people think if finally discarding the old
>>        (non-new_cache) code and using that as an excuse to increment
>>        the major version number of nfs-utils?
>
> Looking at the history....  Looks like that went into 2.5.42 in late
> 2002.  In distro terms, first distros to support the new interface
> include RHEL4, Debian 3.1/Sarge, Suse 9.
>
> No comment on the other stuff, just wanted to check that as I'm inclined
> to extreme conservatism on backwards compatibility.  But, yeah, I guess
> that'd be OK.

Thanks.
On the flip side, kernels since 3.1 (4.5 years ago) cannot make use of
the code I'm suggesting be removed.  So it does feel like it might be time.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYJPY6AAoJEDnsnt1WYoG54N8QAKjA8qHjVbvZWuEtjp+xGucT
tp0CPARSpXhLQG5cxDdbTFe3vcvzOCdtiIwr1HizI7b5gsaxaNTEidHY2bWNwn3v
9dBcYuUUDpVa4xTTNn7iNp/YbPBAzauT96TTLlY9ImRAiVcCWvzQi5bUKaanT3OR
avi4Co4ruNzGC+SNW2bINFRXMI/2qvykih4X1Bi0TKOYnnjY0mA5YMG2lijfOVGO
KbcNRjhT5hcHPYcRMIm6BaVZK6uTbpXsNhodQaFzfTAtprSUwz+k4Qc09sNnKxrQ
HqV3l8yQrRdkhzb2FH5yuHx5CTTwikT+D6Vu8ZxmiIoBx5pv7LIc2oi2VXWKlDiP
rjlrNya+CW/wgOkapGGWvAZFCV5AN3yXM6UP7hfeg5RsS8/A9G6UZXqQTFEUIUCm
HE/LwPmyBQBd780S8q0pi8jjU9hOQSdltlzPGLxZB5oaAivjiqz6A53KBQn0TMT8
KpsdCGlrGrfT6jJA2Co5rt/BfDogsOC/N4cW52KYi8TjBOT5DVIs9cdJudPg1UH/
ti3tE1olXvvfAHpUOBuLGr2ja7AWl/ncRjgRVm4VvxlctdpLTvSpqQ+6y7XB9Ugq
OqelBF65Il4m8pLMqR/CsC+F8/eIDDSDIKdahthGLz1ep1ckCDL9vywj5AucB+Pq
c21uVI5ZHQ8UoZsYp3th
=FBEC
-----END PGP SIGNATURE-----
--=-=-=--
