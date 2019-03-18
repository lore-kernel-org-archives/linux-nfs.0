Return-Path: <SRS0=1lUO=RV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD2E8C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Mar 2019 23:26:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B698F2084F
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Mar 2019 23:26:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726438AbfCRX0o (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Mar 2019 19:26:44 -0400
Received: from mx2.suse.de ([195.135.220.15]:58242 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726303AbfCRX0o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 18 Mar 2019 19:26:44 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id A7896AF23;
        Mon, 18 Mar 2019 23:26:41 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "catalin.marinas\@arm.com" <catalin.marinas@arm.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date:   Tue, 19 Mar 2019 10:26:33 +1100
Cc:     "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "anna.schumaker\@netapp.com" <anna.schumaker@netapp.com>,
        "stable\@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH] NFS: Fix nfs4_lock_state refcounting in nfs4_alloc_{lock,unlock}data()
In-Reply-To: <9cee20976d23acb18c4925b3cc55d34c1369ae83.camel@hammerspace.com>
References: <20190318170028.61423-1-catalin.marinas@arm.com> <9cee20976d23acb18c4925b3cc55d34c1369ae83.camel@hammerspace.com>
Message-ID: <87ef73932u.fsf@notabene.neil.brown.name>
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

On Mon, Mar 18 2019, Trond Myklebust wrote:

> On Mon, 2019-03-18 at 17:00 +0000, Catalin Marinas wrote:
>> Commit 7b587e1a5a6c ("NFS: use locks_copy_lock() to copy locks.")
>> changed the lock copying from memcpy() to the dedicated
>> locks_copy_lock() function. The latter correctly increments the
>> nfs4_lock_state.ls_count via nfs4_fl_copy_lock(), however, this
>> refcount
>> has already been incremented in the nfs4_alloc_{lock,unlock}data().
>> Kmemleak subsequently reports an unreferenced nfs4_lock_state object
>> as
>> below (arm64 platform):
>>=20
>> unreferenced object 0xffff8000fce0b000 (size 256):
>>   comm "systemd-sysuser", pid 1608, jiffies 4294892825 (age 32.348s)
>>   hex dump (first 32 bytes):
>>     20 57 4c fb 00 80 ff ff 20 57 4c fb 00 80 ff ff   WL..... WL.....
>>     00 57 4c fb 00 80 ff ff 01 00 00 00 00 00 00 00  .WL.............
>>   backtrace:
>>     [<000000000d15010d>] kmem_cache_alloc+0x178/0x208
>>     [<00000000d7c1d264>] nfs4_set_lock_state+0x124/0x1f0
>>     [<000000009c867628>] nfs4_proc_lock+0x90/0x478
>>     [<000000001686bd74>] do_setlk+0x64/0xe8
>>     [<00000000e01500d4>] nfs_lock+0xe8/0x1f0
>>     [<000000004f387d8d>] vfs_lock_file+0x18/0x40
>>     [<00000000656ab79b>] do_lock_file_wait+0x68/0xf8
>>     [<00000000f17c4a4b>] fcntl_setlk+0x224/0x280
>>     [<0000000052a242c6>] do_fcntl+0x418/0x730
>>     [<000000004f47291a>] __arm64_sys_fcntl+0x84/0xd0
>>     [<00000000d6856e01>] el0_svc_common+0x80/0xf0
>>     [<000000009c4bd1df>] el0_svc_handler+0x2c/0x80
>>     [<00000000b1a0d479>] el0_svc+0x8/0xc
>>     [<0000000056c62a0f>] 0xffffffffffffffff
>>=20
>> This patch removes the original refcount_inc(&lsp->ls_count) that was
>> paired with the memcpy() lock copying.
>>=20
>> Fixes: 7b587e1a5a6c ("NFS: use locks_copy_lock() to copy locks.")
>> Cc: <stable@vger.kernel.org> # 5.0.x-
>> Cc: NeilBrown <neilb@suse.com>
>> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
>> ---
>>  fs/nfs/nfs4proc.c | 2 --
>>  1 file changed, 2 deletions(-)
>>=20
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 4dbb0ee23432..6d2812a39287 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -6301,7 +6301,6 @@ static struct nfs4_unlockdata
>> *nfs4_alloc_unlockdata(struct file_lock *fl,
>>  	p->arg.seqid =3D seqid;
>>  	p->res.seqid =3D seqid;
>>  	p->lsp =3D lsp;
>> -	refcount_inc(&lsp->ls_count);
>>  	/* Ensure we don't close file until we're done freeing locks!
>> */
>>  	p->ctx =3D get_nfs_open_context(ctx);
>>  	p->l_ctx =3D nfs_get_lock_context(ctx);
>> @@ -6526,7 +6525,6 @@ static struct nfs4_lockdata
>> *nfs4_alloc_lockdata(struct file_lock *fl,
>>  	p->res.lock_seqid =3D p->arg.lock_seqid;
>>  	p->lsp =3D lsp;
>>  	p->server =3D server;
>> -	refcount_inc(&lsp->ls_count);
>>  	p->ctx =3D get_nfs_open_context(ctx);
>>  	locks_init_lock(&p->fl);
>>  	locks_copy_lock(&p->fl, fl);
>
> Thanks Catalin! Good catch...
>
> I'm applying this to my linux-next branch.
>

Yes, thanks a lot!  I wonder how I missed that :-(

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlyQKSkACgkQOeye3VZi
gblvCw/9HLJERM/vi8buewpJF4ihP8NWW+Z8NLV9EmrPkW/Rb+Y9CXjjC8/w6Qx1
4n1denVEYXC1XQyhjGZArgKepvvzW5EpiqA4bMpxe8vcxCFWYXK89pp+GCZVgeSc
yLaghL1mZZDHRRa9QVQ4a5J3pHkhqdNLyCDooaJN8barRb+8t36MUMtLYmm10hYE
3Hwr+9TAFtFMU+UIecS4ouGcH0qkK4QRsNfG6YbMeHxGOekslmohcpgrVsFR+Rpv
jKqWUUkqsS5gsHNYDUP2m7/R7J7ZUIMicswSDh/U7mDZ0yxNYJJpZzP/s+CwEBII
DW5lXemmmYdCULIQe94eQ9gHKpHqy+YGiI1OU7P1PQ7q6ogE6U6X/3HJ3Oc6fz0g
Wl00eVaAFPMHW8G7+gBD1QmRkEq2qICgTaz3MkL7FqZXvrPwMOhCSpbzrFsZ00EC
b1x95wuwPjbZv5u5wrx3ht/SodxfXd572tgJ1ATCHrXJiDi0Q+qqnv3/aIQOGbzz
y1Q7q14KA1Pfy33x2eF2wCHCpn9DcRjOq+Rq3u/bNw93CcCBQxgPgAikdWaYjyPC
/xw4VXAtnLmigdIigxyQleG3dHSu9YPRajW/ccTXgI38Eo290q/oDg+LL39gKCk2
SIUIYn9HV/8BmcOozrN35GPSwpJCaYRl+jiYezDhIHx9kF4Wg5M=
=B9c6
-----END PGP SIGNATURE-----
--=-=-=--
