Return-Path: <SRS0=vcFy=S4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86112C4321B
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Apr 2019 23:55:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 55493206E0
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Apr 2019 23:55:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727114AbfDZXzg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Apr 2019 19:55:36 -0400
Received: from mx2.suse.de ([195.135.220.15]:39430 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726974AbfDZXzg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 Apr 2019 19:55:36 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 41E82ACBD;
        Fri, 26 Apr 2019 23:55:34 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Andreas Dilger <adilger@dilger.ca>
Date:   Sat, 27 Apr 2019 09:55:23 +1000
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        James Simmons <uja.ornl@gmail.com>
Subject: Re: [PATCH 00/10] exposing knfsd opens to userspace
In-Reply-To: <20190426125611.GA23112@fieldses.org>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com> <B37B2837-E8C8-41EA-9A2D-3F8B93304FDD@dilger.ca> <87lfzx65ax.fsf@notabene.neil.brown.name> <60EB550C-B79C-4DB4-AE3D-F1FCEB49EDA1@dilger.ca> <20190426125611.GA23112@fieldses.org>
Message-ID: <87imv05nkk.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 26 2019, J. Bruce Fields wrote:

> On Fri, Apr 26, 2019 at 01:00:19PM +0200, Andreas Dilger wrote:
>>=20
>> On Apr 26, 2019, at 1:20 AM, NeilBrown <neilb@suse.com> wrote:
>> > /proc/fs/nfsd is the (standard) mount point for a separate NFSD-specif=
ic
>> > filesystem, originally created to replace the nfsd-specific systemcall.
>> > So the nfsd developers have a fair degree of latitude as to what can go
>> > in there.
>> >=20
>> > But I *don't* think it is a good idea to follow this pattern.  Creating
>> > a separate control filesystem for every different module that thinks it
>> > has different needs doesn't scale well.  We could end up with dozens of
>> > tiny filesystems that all need to be mounted at just the right place.
>
> Aren't we already there?  My laptop, Fedora 29 with everything pretty much
> default:
>
> $  findmnt -n -oFSTYPE|sort|uniq -c
>       1 autofs
>       1 bpf
>      11 cgroup
>       1 cgroup2
>       1 configfs
>       1 debugfs
>       1 devpts
>       1 devtmpfs
>       3 ext4
>       1 fusectl
>       1 fuse.gvfsd-fuse
>       1 hugetlbfs
>       1 mqueue
>       1 proc
>       1 pstore
>       1 rpc_pipefs
>       1 securityfs
>       1 selinuxfs
>       1 sysfs
>       5 tmpfs

Sometimes I think "Linux is so full of crap, it hardly matters if more
crap is added".  Other times I feel a bit more social responsibility and
want to fight against adding too much more crap.

>
>> > I don't think that is healthy for Linus.
                                       ^^^^^ oops
>
> What are the problems you see?

Fragmentation.
This is exactly the platform problem.  People look at the existing
functionality, decide that it doesn't quite meet their needs, and then
do an implement something that is mostly the same but just different
enough so that they feel more comfortable.

We have 'seq_file' which encourages people to create line-oriented info
files, but if some have tab-separate lines, others have CSV, others have
yaml etc, then there is plenty of room for confusion.

If we could, instead, just agreed that more structured data actually can
make sense in sysfs, and come up with a coherent approach that we can
all tolerate, then life would be much easier.

>
>> > Nor do I think we should be stuffing stuff into debugfs that isn't
>> > really for debugging.  That isn't healthy either.
>> >=20
>> > If sysfs doesn't meet our needs, then we need to raise that in
>> > appropriate fora and present a clear case and try to build consensus -
>> > because if we see a problem, then it is likely that others do to.
>>=20
>> I definitely *do* see the restrictions sysfs as being a problem, and I'd
>> guess NFS developers thought the same,
>
> For what it's worth, the nfsd filesystem predated sysfs, just barely.
>
> Looking at the history....  It was actually Al that introduced it in March
> 2002.  Patrick Mochel added sysfs in October 2002.

IIRC the nfsd filesystem was added to address the difficulty of
supporting a systemcall in a module.  That basically doesn't work, so
there needed to be some clean interface between some minimal nfsdctl system=
call
code that was always compiled in, and the actually implementation that
could be in a module.  It was Viro who particularly noticed this need,
so it was a filesystem that was chosen to fill the need - filesystems in
modules was already a solved problem.
The system call was (I think) write-only (no non-trivial return data)
and each file just recieved a binary struct that matches the syscall
argument.
Once that was in place, it became a dumping ground for whatever we
wanted.

sysfs was, I think, originally about power management.  It exposed
connections between devices more than the devices themselves.  This
allowed user-space to be able to power-things down when not in use, and
to understand the dependencies.
Since then it grew....

>
> But it's true that from the start nfsd didn't really fit the model of a s=
ingle
> (possibly writeable) attribute per file.

Depends on what you mean by that.  Original files where write-only and
where slightly complex attributes. Writing performed an action, like
adding an entry to the export table (first you add a client, then add a
client+filesystem to export it).

This idea for a file performing an action, rather than presenting an
attribute, is much the same as the "bind" and "unbind" files you can
find in sysfs.

(see also https://lwn.net/Articles/378884/ for examples of sysfs files
that are not one-attribute-per-file)

NeilBrown

>
> (Might be interesting to look at the distribution of new filesystem types=
 over
> time, there may have been a peak around then.)
>
> --b.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlzDmmwACgkQOeye3VZi
gbkF6hAApgAqkwa/tsFNphcxDpNMiXINCbYRSxdT2BkACuZ1wqrW87nEEos0BzOX
BtVfY50J5FLPMHG3LpiZJauOZQR9Pvbqz8GK7GR4TvD4d1Szv+MMKXwHA4ErYYES
yS8qOo+MDOFe1AJ4lrRHFKNPrBT6yBn3/5yoZPo0+AhyeeRygVHPgUZIDT8p4KmW
arF00bLP+q4cCC+CDJMzYX3BQYuZBpybZ+hvkYxlmF/hgGDjCI5qiPLggQgPQOxf
R7GTLie9+zWfCM3knRYX/3Znp4Batrvmo/N2E5ijAV/CrDy4BmBAEj/CwjfO2w6A
1gSQMyHhUWLt4sxbZaWCsh7C7ATexk5jMWF+4TiqQxozymgW6tXJlBDaK6O2+E9Z
jBw/Ewcpbptjx9oKsufUBE7YvK9YSzjCT71xELzeS8zSaKM8VNuFmTvnn3GI6Mqb
C6TSq6PwB0s+8lVDP+fS7nLn7U6c+85/qRa7l3VpI2pUd6IfZuGY+eJLWh0h/DWM
k0wSQ18/n5hJySJVwJOwStIO061CePNU+WtVAdVzk8sTrBLGLXlRfog4rw5bpL5R
LUa1V++OH24FtwU1AwEtwcx9HttoDsDohWS9ZQuoapOJWRYQZlnFqes9jaILVCbx
WCz1tMF8zbTNOTh555smA4EWL8FC0sHbTTPpMPR4QBxmCow/RQ0=
=MnnB
-----END PGP SIGNATURE-----
--=-=-=--
