Return-Path: <SRS0=HBvY=OW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C6E8C65BAE
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Dec 2018 03:55:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 49ED420870
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Dec 2018 03:55:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49ED420870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726535AbeLMDz4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 22:55:56 -0500
Received: from mx2.suse.de ([195.135.220.15]:60860 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726298AbeLMDz4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Dec 2018 22:55:56 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 100A4AE54;
        Thu, 13 Dec 2018 03:55:54 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Ashish Sangwan <ashishsangwan2@gmail.com>
Date:   Thu, 13 Dec 2018 14:55:48 +1100
Cc:     linux-nfs@vger.kernel.org
Subject: Re: Handling of duplicate inode numbers for the directories in the nfs v3 kernel client
In-Reply-To: <CAOiN93=bh8WrCD8gZ+En4EfzTv2iHMn5n4w5=rYJOr6RbUkCKQ@mail.gmail.com>
References: <CAOiN93mX240ijc8mcX1OSKrQaP12At9t5c9cE3-T0gEuLC9RkA@mail.gmail.com> <878t0uuzxv.fsf@notabene.neil.brown.name> <CAOiN93=bh8WrCD8gZ+En4EfzTv2iHMn5n4w5=rYJOr6RbUkCKQ@mail.gmail.com>
Message-ID: <87zhtat70b.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--=-=-=
Content-Type: text/plain

On Thu, Dec 13 2018, Ashish Sangwan wrote:

> Thanks for the clarification!
>
> On Thu, 13 Dec 2018, 4:15 am NeilBrown <neilb@suse.com wrote:
>>
>> On Thu, Dec 13 2018, Ashish Sangwan wrote:
>>
>> > Hi,
>> >
>> > Our NFS filer can sometimes return same inode number for different directories.
>>
>> Why?
> The NFS fileserver is handling file systems over different nodes at
> the same time.
> To the client however, we want to present with a single pseudo fsid
> (sent as part of the getattr) so that submounts can be avoided.
> We have assigned unique numbers to identify different file systems and
> we append those numbers to the actual on-disk inode numbers to avoid
> the collision.  But in some rare cases there is not enough free bits
> in the inode to accommodate the unique filesystem identifier.
>
>>
>> > For example /mnt/dir1/dir2 and /mnt/dir3/dir4, in same rare cases dir2
>> > and dir4 might end up returning the same inode number to the client.
>> > Though it can never happen that inode numbers will be same for two
>> > directories and also there parent is same. Can linux client handle
>> > this case? What issues it can cause?
>>
>> As long as the file handles are different, the Linux client won't really
>> notice.
> A naive question here. This should also not cause any issue in the VFS layer?

No, the VFS layer won't notice duplicates.

NeilBrown


>
>> Problems might occur with applications which check inode numbers.
>> I don't know of any that would be confused by directories having the
>> same inode number, but that doesn't mean there aren't any.
>>
>> > https://lkml.org/lkml/2006/10/2/346
>>
>> This is ancient!  It is mostly about the NFS server, not the client.
>> Filesystems that NFSd is exporting need to be careful to provide unique
>> file handles.
>>
>> > I stumbled upon this thread where it is written that nfs client can
>> > handle this but userspace will see inode collisions. Given that this
>> > will happen only for directories, userspace utils logic might not get
>> > affected from this as hardlinks on directories are not possible. But
>> > the thread is really old. Wanted to confirm if this holds true even
>> > now.
>>
>> I don't think anything important has changed.  The server must return
>> unquie filehandles.  It should return unique inode numbers.  User-space
>> may or may not get confused if it doesn't.
> Understood that this has to be fixed ultimately. Just wanted to have
> an idea regarding the severity of the issue.
>>
>> NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlwR2EQACgkQOeye3VZi
gbkIlw//YL5Xgv2o/6rnxAgSJEuO+NQbReNSokzlmxHHjeaNAs0j8RGLZ47susPE
M/bGTJSWDOwVybPMM46OdXEIUBLw8SCAKp8ab63F5obEchVHnXN1d4OKqCTZBTNz
+vVjP3GXYQXyzduzXIITDTXZ2Y9imw+p57cyYMWop8YcoWW47PFDd6J8t4N3TYkB
1JfM6suCdRPM1boKnQea6Pcar7kiJjUbjlSkRAJGRaL8rarTHPWYKaPQPIO3bcv4
VqaZxtfuF6AjGMVZ7kAm3neqlk4fzgA0IefKudQ5hjmm/negRahUQJjt1eDXA/Fu
/BYueg12UCviW5A78zdN2OAoV62VwYi0tJF5K55WAKDwxxY/5Zqtgw4oD9MNGhn1
6C91ik85bnj7PootgCyxK1kZQCB38pG5VtsfzJ+FPBevFusqB20qubCWU5CuSXI6
YA6rzzMMvNkZvArZluWhZ/A7E9jkdYPlAfo+6nfQMZyfl7tw1BfjpyHDBTgkuUiI
LiQPnFoG+bor7mn/HskFNqB/sFxRy26G0A/Xs0VmLgtnieZZlxSG0htie7xCa5Sc
5D5VtvOA/M/Hz9yQNGj5Gp7K6KJUUTcYgRppfZFCtmdl2gUUsX9uwuynX2wnY+Sd
byJcHxtfn5YR5R60gXDaTwiI8vBQEb0vUY0neXBEWLcncSGAjw0=
=k0H0
-----END PGP SIGNATURE-----
--=-=-=--
