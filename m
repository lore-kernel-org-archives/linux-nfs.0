Return-Path: <SRS0=vcFy=S4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0A04C43218
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Apr 2019 11:00:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A9CAC206E0
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Apr 2019 11:00:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=dilger-ca.20150623.gappssmtp.com header.i=@dilger-ca.20150623.gappssmtp.com header.b="RmPIWM+5"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726189AbfDZLA2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Apr 2019 07:00:28 -0400
Received: from mail-wm1-f66.google.com ([209.85.128.66]:40183 "EHLO
        mail-wm1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726176AbfDZLA2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Apr 2019 07:00:28 -0400
Received: by mail-wm1-f66.google.com with SMTP id h11so3762054wmb.5
        for <linux-nfs@vger.kernel.org>; Fri, 26 Apr 2019 04:00:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dilger-ca.20150623.gappssmtp.com; s=20150623;
        h=from:message-id:mime-version:subject:date:in-reply-to:cc:to
         :references;
        bh=CcXLTvHQ5XlxvbCLC8H6MmH7ACT6y3/M0hXzAKZtnpw=;
        b=RmPIWM+5NRnaltjS1gkl1ux19GIiT/HOJ2SrpvAczo8zKeVgpcG7VOzan/SanDJPMf
         sQcOwvlcMKphdeXI3Rsg1sHdocfgn9N0F5ygLFLSJ/THF7DPb/1NVlOmHB29iPSHS7Rj
         AgvR8MZ41yzs2EdxvWJbYKmYTPZxbwRsdjE9ojwx/MKDjrr4I3v9bJIl+T8WVZCCnxyA
         IdboHKG/Q1IQsDFEumUeaXIrsbPMxk/6wz5V5hIAxIIKQeBWbGdLt5ThbT7M+MGc9wov
         G69GflJKI7aFI5YBWag1BUbn1MpoG7dZ87o4NIr6HNWjGfaiubmiu3k2aU59fFiUT1uO
         KkZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:message-id:mime-version:subject:date
         :in-reply-to:cc:to:references;
        bh=CcXLTvHQ5XlxvbCLC8H6MmH7ACT6y3/M0hXzAKZtnpw=;
        b=irwXMueiC3AWOXSoaUq/D3mSLRJUMY8PYd+QTUOYshcNsnKeNI/Eb0AG9EpcwNp8dC
         kZ729FlxiW7VEa1h0cY8rT8ojaGYaI6XujRKCyTEMLdnngYYcSYHHVPZCo6XLryUzqjZ
         BcyGMP9wf940pryXQqHHkAhJmMiID6kDlCQNCzcqTV9oUaKGbYdY1mblSVaXUvGsW0DQ
         BCHyV5L2eIbb+youDn/3zzOIXgH6cJwwgElx3+39a+iCqzow5zeAx6UAM2mzZOjrMiaL
         FRAjNbtLrnvkf7J5LsbjB9xDsTQwfh3/biz30ExoFtK5hbmjA0V1wHMBBkov1jPMoXTL
         E3VA==
X-Gm-Message-State: APjAAAX2TekuAMvLxrSKj31hek6A+nDsLGGsyXTYnQFIJSXJ71FCMF5z
        Fw/iF2g8bZXIgtdigbE9SErNbQ==
X-Google-Smtp-Source: APXvYqynAesi1wUtu/SJUWyeASAOr4MWRLJ9J7qBdym1LYLNpIGoSGkyJdiU0uBtWIPY962a+ywIyA==
X-Received: by 2002:a1c:4844:: with SMTP id v65mr7301019wma.139.1556276425671;
        Fri, 26 Apr 2019 04:00:25 -0700 (PDT)
Received: from [172.16.14.23] ([37.205.61.202])
        by smtp.gmail.com with ESMTPSA id e7sm15440499wrp.19.2019.04.26.04.00.24
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 04:00:24 -0700 (PDT)
From:   Andreas Dilger <adilger@dilger.ca>
Message-Id: <60EB550C-B79C-4DB4-AE3D-F1FCEB49EDA1@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_6E2EB144-AA73-4E88-B66E-FA480431BD4C";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 00/10] exposing knfsd opens to userspace
Date:   Fri, 26 Apr 2019 13:00:19 +0200
In-Reply-To: <87lfzx65ax.fsf@notabene.neil.brown.name>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        James Simmons <uja.ornl@gmail.com>
To:     NeilBrown <neilb@suse.com>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com>
 <B37B2837-E8C8-41EA-9A2D-3F8B93304FDD@dilger.ca>
 <87lfzx65ax.fsf@notabene.neil.brown.name>
X-Mailer: Apple Mail (2.3273)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


--Apple-Mail=_6E2EB144-AA73-4E88-B66E-FA480431BD4C
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


> On Apr 26, 2019, at 1:20 AM, NeilBrown <neilb@suse.com> wrote:
>=20
> On Thu, Apr 25 2019, Andreas Dilger wrote:
>=20
>> On Apr 25, 2019, at 4:04 PM, J. Bruce Fields <bfields@redhat.com> =
wrote:
>>>=20
>>> From: "J. Bruce Fields" <bfields@redhat.com>
>>>=20
>>> The following patches expose information about NFSv4 opens held by =
knfsd
>>> on behalf of NFSv4 clients.  Those are currently invisible to =
userspace,
>>> unlike locks (/proc/locks) and local proccesses' opens =
(/proc/<pid>/).
>>>=20
>>> The approach is to add a new directory /proc/fs/nfsd/clients/ with
>>> subdirectories for each active NFSv4 client.  Each subdirectory has =
an
>>> "info" file with some basic information to help identify the client =
and
>>> an "opens" directory that lists the opens held by that client.
>>>=20
>>> I got it working by cobbling together some poorly-understood code I
>>> found in libfs, rpc_pipefs and elsewhere.  If anyone wants to wade =
in
>>> and tell me what I've got wrong, they're more than welcome, but at =
this
>>> stage I'm more curious for feedback on the interface.
>>=20
>> Is this in procfs, sysfs, or a separate NFSD-specific filesystem?
>> My understanding is that "complex" files are verboten in procfs and =
sysfs?
>> We've been going through a lengthy process to move files out of =
procfs
>> into sysfs and debugfs as a result (while trying to maintain some =
kind of
>> compatibility in the user tools), but if it is possible to use a =
separate
>> filesystem to hold all of the stats/parameters I'd much rather do =
that
>> than use debugfs (which has become root-access-only in newer =
kernels).
>=20
> /proc/fs/nfsd is the (standard) mount point for a separate =
NFSD-specific
> filesystem, originally created to replace the nfsd-specific =
systemcall.
> So the nfsd developers have a fair degree of latitude as to what can =
go
> in there.
>=20
> But I *don't* think it is a good idea to follow this pattern.  =
Creating
> a separate control filesystem for every different module that thinks =
it
> has different needs doesn't scale well.  We could end up with dozens =
of
> tiny filesystems that all need to be mounted at just the right place.  =
I
> don't think that is healthy for Linus.
>=20
> Nor do I think we should be stuffing stuff into debugfs that isn't
> really for debugging.  That isn't healthy either.
>=20
> If sysfs doesn't meet our needs, then we need to raise that in
> appropriate fora and present a clear case and try to build consensus -
> because if we see a problem, then it is likely that others do to.

I definitely *do* see the restrictions sysfs as being a problem, and I'd
guess NFS developers thought the same, since the "one value per file"
paradigm means that any kind of complex data needs to be split over
hundreds or thousands of files, which is very inefficient for userspace =
to
use.  Consider if /proc/slabinfo had to follow the sysfs paradigm, this =
would
(on my system) need about 225 directories (one per slab) and 3589 =
separate
files in total (one per value) that would need to be read every second =
to
implement "slabtop".  Running strace on "top" shows it taking 0.25s wall =
time
to open and read the files for only 350 processes on my system, at 2 =
files
per process ("stat" and "statm"), and those have 44 and 7 values, =
respectively,
so if it had to follow the sysfs paradigm would make this far worse.

I think it would make a lot more sense to have one file per item of =
interest,
and make it e.g. a well-structured YAML format ("name: value", with =
indentation
denoting a hierarchy/grouping of related items) so that it can be both =
human
and machine readable, easily parsed by scripts using bash or awk, rather =
than
having an explicit directory+file hierarchy.  Files like /proc/meminfo =
and
/proc/<pid>/status are already YAML-formatted (or almost so), so it =
isn't ugly
like XML encoding.

> This is all presumably in the context of Lustre and while lustre is
> out-of-tree we don't have a lot of leverage.  So I wouldn't consider
> pursuing anything here until we get back upstream.

Sure, except that is a catch-22.  We can't discuss what is needed until
the code is in the kernel, but we can't get it into the kernel until the
files it puts in /proc have been moved into /sys?

Cheers, Andreas






--Apple-Mail=_6E2EB144-AA73-4E88-B66E-FA480431BD4C
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAlzC5MQACgkQcqXauRfM
H+Bldw//W7JIZMd0tYH2obw2+eggICHgDlNjliw168VS7FTS67ga/JsoteOly9rr
SpwkSG+4PRKtflTS83a26b20ASqDYSBSHA+Ge3Hg7PA3ec94/+yYN2bGcOATW5OD
4Dv2ySQ2NFZT5yjsTWFjEwKC/ZFjEqb2ouapiTD/H+Q+/TtyrkF4x+lMOfcHqEsl
fYwGs0dIZOvw5lRzafTSZSHcFmhbwIppjYXukk9qAMa3CfMtPhTmkGMgHsoeAhBa
H6hyhb5E+JiwbotPMnfakw5e1LFlmZ6eXkKm0ofuaMZKZ7i6rUP1jJagYIAK6V8H
fbOJTGqHaHRcJKU8NsMNhWEZwlGDjdFibbq1su1HS0xdMdYQyUAtW9Udc+MBWKsb
4LAa/r7n6YwSlzh6fZNDdfDOwMkk1F/xd5U/lLrp7erInKWrk+1hH3KcEdbNdo+R
T/mQc2Jb1S1uzKz03K4No3lm9O8EQHkeancqdeGzqsyR6vr58KGg/cXQZDDAReHf
uuirAPYnRx0RczadMPFir1klCogQu6/UJdJyatbCA7nI2t653T6jJCK9ZfQYMrPn
+9zkx/GPR/Dm5sup8/Sk1YezHDpIBLWYpm43h5JMhrKT8x9+7Iw6FMrpw4D98OBR
N1ykXIISiYrxwXYF7u19l4dIbtUrU/y3PU7SQ5I0iNjqyD4XQ2M=
=oiNN
-----END PGP SIGNATURE-----

--Apple-Mail=_6E2EB144-AA73-4E88-B66E-FA480431BD4C--
