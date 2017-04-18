Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bl2nam02on0104.outbound.protection.outlook.com ([104.47.38.104]:55749
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753293AbdDRRG3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Apr 2017 13:06:29 -0400
From: "Chandy, John" <john.chandy@uconn.edu>
To: Boaz Harrosh <ooo@electrozaur.com>
CC: Christoph Hellwig <hch@lst.de>,
        "martin.petersen@oracle.com" <martin.petersen@oracle.com>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "axboe@kernel.dk" <axboe@kernel.dk>,
        "osd-dev@open-osd.org" <osd-dev@open-osd.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: RFC: drop the T10 OSD code and its users
Date: Tue, 18 Apr 2017 17:06:25 +0000
Message-ID: <1F41407D-B78F-46E3-8FBE-90A5B1E5C3DE@uconn.edu>
References: <20170412160109.10598-1-hch@lst.de>
 <13c543db-dd38-1825-a58d-b4dff99e5f3c@electrozaur.com>
In-Reply-To: <13c543db-dd38-1825-a58d-b4dff99e5f3c@electrozaur.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As one of those academics that Boaz was talking about, we do use the OSD dr=
iver for various research projects including support for OSD in parallel fi=
le systems like OrangeFS and Lustre.

John.

> On Apr 18, 2017, at 12:24 PM, Boaz Harrosh <ooo@electrozaur.com> wrote:
>=20
> On 04/12/2017 07:01 PM, Christoph Hellwig wrote:
>=20
> Hi Sir Christoph
>=20
>> The only real user of the T10 OSD protocol, the pNFS object layout
>> driver never went to the point of having shipping products, and the
>> other two users (osdblk and exofs) were simple example of it's usage.
>>=20
>=20
> I understand why osdblk might be a pain, and was broken from day one, and
> should by all means go away ASAP.
>=20
> But exofs should not be bothering anyone, and as far as I know does
> not use any special API's except the osd_uld code of course.
>=20
>> The code has been mostly unmaintained for years and is getting in the
>> way of block / SCSI changes, so I think it's finally time to drop it.
>>=20
>=20
> Please tell me what are those changes you are talking about? I might be
> able to help in conversion. I guess you mean osd_uld and the Upper SCSI A=
PI.
> Just point me at a tree where osd_uld is broken, and perhaps with a littl=
e
> guidance from you I can do a satisfactory conversion.
>=20
> Is true that no new code went in for a long while, but I still from time
> to time run a setup and test that the all stack, like iscsi-bidi and so o=
n still
> works.
>=20
> That said, yes only a stand alone exofs was tested for a long time, a ful=
l
> pnfs setup is missing any supporting server. So Yes I admit that pnfs-obj=
 is
> getting very rotten. And is most probably broken, on the pnfs side of thi=
ngs.
> [Which I admit makes my little plea kind of mute ;-) ]
>=20
> Every once in a while I get emails from Students basing all kind of inter=
esting
> experiments on top of the exofs and object base storage. So for the sake =
of academics
> and for the sake of a true bidi-stack testing, might we want to evaluate =
what is the
> up coming cost, and what is a minimum set we are willing to keep?
>=20
> Please advise?
>=20
> thanks
> Boaz
>=20
>> These patches are against Jens' block for-next tree as that already
>> has various modifications of the SCSI code.
>>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

