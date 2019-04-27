Return-Path: <SRS0=TJwb=S5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A359C4321A
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Apr 2019 00:03:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 15EB020873
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Apr 2019 00:03:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727123AbfD0ADL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Apr 2019 20:03:11 -0400
Received: from mx2.suse.de ([195.135.220.15]:40058 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726817AbfD0ADL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 Apr 2019 20:03:11 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 87D2BAD96;
        Sat, 27 Apr 2019 00:03:09 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Andreas Dilger <adilger@dilger.ca>
Date:   Sat, 27 Apr 2019 10:03:02 +1000
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        James Simmons <uja.ornl@gmail.com>
Subject: Re: [PATCH 00/10] exposing knfsd opens to userspace
In-Reply-To: <60EB550C-B79C-4DB4-AE3D-F1FCEB49EDA1@dilger.ca>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com> <B37B2837-E8C8-41EA-9A2D-3F8B93304FDD@dilger.ca> <87lfzx65ax.fsf@notabene.neil.brown.name> <60EB550C-B79C-4DB4-AE3D-F1FCEB49EDA1@dilger.ca>
Message-ID: <87ftq45n7t.fsf@notabene.neil.brown.name>
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

On Fri, Apr 26 2019, Andreas Dilger wrote:

>> On Apr 26, 2019, at 1:20 AM, NeilBrown <neilb@suse.com> wrote:
>>=20
>> On Thu, Apr 25 2019, Andreas Dilger wrote:
>>=20
>>> On Apr 25, 2019, at 4:04 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>>>>=20
>>>> From: "J. Bruce Fields" <bfields@redhat.com>
>>>>=20
>>>> The following patches expose information about NFSv4 opens held by knf=
sd
>>>> on behalf of NFSv4 clients.  Those are currently invisible to userspac=
e,
>>>> unlike locks (/proc/locks) and local proccesses' opens (/proc/<pid>/).
>>>>=20
>>>> The approach is to add a new directory /proc/fs/nfsd/clients/ with
>>>> subdirectories for each active NFSv4 client.  Each subdirectory has an
>>>> "info" file with some basic information to help identify the client and
>>>> an "opens" directory that lists the opens held by that client.
>>>>=20
>>>> I got it working by cobbling together some poorly-understood code I
>>>> found in libfs, rpc_pipefs and elsewhere.  If anyone wants to wade in
>>>> and tell me what I've got wrong, they're more than welcome, but at this
>>>> stage I'm more curious for feedback on the interface.
>>>=20
>>> Is this in procfs, sysfs, or a separate NFSD-specific filesystem?
>>> My understanding is that "complex" files are verboten in procfs and sys=
fs?
>>> We've been going through a lengthy process to move files out of procfs
>>> into sysfs and debugfs as a result (while trying to maintain some kind =
of
>>> compatibility in the user tools), but if it is possible to use a separa=
te
>>> filesystem to hold all of the stats/parameters I'd much rather do that
>>> than use debugfs (which has become root-access-only in newer kernels).
>>=20
>> /proc/fs/nfsd is the (standard) mount point for a separate NFSD-specific
>> filesystem, originally created to replace the nfsd-specific systemcall.
>> So the nfsd developers have a fair degree of latitude as to what can go
>> in there.
>>=20
>> But I *don't* think it is a good idea to follow this pattern.  Creating
>> a separate control filesystem for every different module that thinks it
>> has different needs doesn't scale well.  We could end up with dozens of
>> tiny filesystems that all need to be mounted at just the right place.  I
>> don't think that is healthy for Linus.
>>=20
>> Nor do I think we should be stuffing stuff into debugfs that isn't
>> really for debugging.  That isn't healthy either.
>>=20
>> If sysfs doesn't meet our needs, then we need to raise that in
>> appropriate fora and present a clear case and try to build consensus -
>> because if we see a problem, then it is likely that others do to.
>
> I definitely *do* see the restrictions sysfs as being a problem, and I'd
> guess NFS developers thought the same, since the "one value per file"
> paradigm means that any kind of complex data needs to be split over
> hundreds or thousands of files, which is very inefficient for userspace to
> use.  Consider if /proc/slabinfo had to follow the sysfs paradigm, this w=
ould
> (on my system) need about 225 directories (one per slab) and 3589 separate
> files in total (one per value) that would need to be read every second to
> implement "slabtop".  Running strace on "top" shows it taking 0.25s wall =
time
> to open and read the files for only 350 processes on my system, at 2 files
> per process ("stat" and "statm"), and those have 44 and 7 values, respect=
ively,
> so if it had to follow the sysfs paradigm would make this far worse.
>
> I think it would make a lot more sense to have one file per item of inter=
est,
> and make it e.g. a well-structured YAML format ("name: value", with inden=
tation
> denoting a hierarchy/grouping of related items) so that it can be both hu=
man
> and machine readable, easily parsed by scripts using bash or awk, rather =
than
> having an explicit directory+file hierarchy.  Files like /proc/meminfo and
> /proc/<pid>/status are already YAML-formatted (or almost so), so it isn't=
 ugly
> like XML encoding.

So what are your pain points?  What data do you really want to present in
a structured file?
Look at /proc/self/mountstats on some machine which has an NFS mount.
There would be no problem adding similar information for lustre mounts.

What data do you want to export to user-space, which wouldn't fit there
and doesn't fit the one-value-per-file model.  To make a case, we need
concrete data.

>
>> This is all presumably in the context of Lustre and while lustre is
>> out-of-tree we don't have a lot of leverage.  So I wouldn't consider
>> pursuing anything here until we get back upstream.
>
> Sure, except that is a catch-22.  We can't discuss what is needed until
> the code is in the kernel, but we can't get it into the kernel until the
> files it puts in /proc have been moved into /sys?

Or maybe just removed.  If lustre is usable without some of these files,
then we can land lustre without them, and then start the conversation
about how to export the data that we want exported.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlzDnDYACgkQOeye3VZi
gbnRpxAAgj6FbDTeZtUumvr1Njqtkn/1I4J4Yepp85bLg+b6Mo0C/oKN8rAJWE/0
uF+FjLLRB8Frj3/WRVTU4E7xs3xOiuTGMnQ5J4kL6JtibVQeLPfWdaiOTKr0cwTr
2RSRU+BNQ8cP4n243aHdl7L1I1QYI4P8B817ONlPobXeojlhzfCcbHBraqFmNXQ3
K7YcaC/1z/ZL/02J2vuI1YyBHDT1fLxArGdO1SGJqTLiOBHU/GmDWzS7wXIdN99Y
oztCQReA0peuWI5x5ugFtJRIRwQdqs5y7hmgsnKyi6a1/jlmKhdOF2HAMhsGvmtI
vH62WEETPsQj825ZDuaVW0aiWzX+K4j7xHE4kUwWhPaDPF2s1jOVWNu5K7x/OJ5i
ycrCWE2F6GDS9zq73CsE0sfZAw8OHUbxVzvwCFRVrHjtdQ0a4aj/hljS51W2F0Hc
+NvUi1n9Xda8+1W3LGwXUOtyGncDaPbPQ3Z47oG8xb3MG/CDuvv/5/InTOLJr6SZ
ykMU3p8NOtG/92dqlASt+kNOcxll7n+VGLX5NNxGmXkMhGN2g+XgqRUKDDriYUxb
zdOex3ivolSt0HQL2xJiQHNRb1pfqNb2d170xMSRABuW8HZEYvbNgNPYqGhDmKf5
0AaUCoW1rQJmspeLol3WXIcZ1gmo9gyeLLjEwANSro7e+lh+QQU=
=nvLh
-----END PGP SIGNATURE-----
--=-=-=--
