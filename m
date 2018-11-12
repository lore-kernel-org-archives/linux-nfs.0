Return-Path: <SRS0=lcGf=NX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BE83C43610
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 18:16:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C085522419
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 18:16:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GOa8lbVV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C085522419
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728119AbeKMELL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Nov 2018 23:11:11 -0500
Received: from mail-pg1-f194.google.com ([209.85.215.194]:44156 "EHLO
        mail-pg1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727247AbeKMELL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2018 23:11:11 -0500
Received: by mail-pg1-f194.google.com with SMTP id w3-v6so4403454pgs.11
        for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2018 10:16:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=Q3hmI8GtyQRKzT88fft5l6niFcNW7BfLkbwuvhwkMeE=;
        b=GOa8lbVVPhZhi7x1OIcQ+6txe/3/EyAMJxC9FH7dE7UCsfbBC7yIfJuoiTpGtjRZZf
         oVDCIJHfgNw0MchPr+UmS2uZtgv7cDjc2WYczW7tqvyuD0NJ4XNxsesrK1gTJkymKfPJ
         2kHKrMBwkYR/2ddwVMPszO0h2CpTQaJ5K5RJFuXO3LdB4R3Y+XT9BSXGqTGBoKehawlr
         RkfKAVEJDPcmIiHH9QS25/Yz29nRsFeqxD7uTTBwjkRVvmUkph+3nfagnwN226u6zXm/
         J9NVbIba9OFvkHJpseQPHiiA8qk+xkzkEO8Yus+PcV+8O2cGp1/0jdka756fltbLN4WB
         7PSQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=Q3hmI8GtyQRKzT88fft5l6niFcNW7BfLkbwuvhwkMeE=;
        b=rrCCouFnnfOvV7mpB0S+C4wOQsVqnsC7FJDJ3SCfXrjVLmQPM3okPrRpnWf5up34DX
         KdTYUfLG5YzfcjwKI0E0sbZv35YMtpbnaYODVJDvPSyZ913gXoVE2DeAsgwssLLGVcAa
         VB3i+XDcxk6AWwqUfUlOFaIHmsWwd2KMRYqGU5TUU3bJWez/yx9dxXeX0i+CCx2E40sc
         k2lSX02mDJvrEIs8Z38N2f/nrVPl1oKBPAyOdhnV92btz93V8uq+boIBbE44EL1KVz3Y
         jBRX3oKkgD+vKBL6dlIINiBjOIIW/kn3sZjw8uDu0YPLyToXRUtudPVwWz+ugBHiIjr1
         rfjA==
X-Gm-Message-State: AGRZ1gIyIaMbFTzeaJOQHX5mfVFRSDy5nOqovXsk3hn9jm6NVVMuFkQi
        WF2idR8Yx7MPof/JywHqTPs=
X-Google-Smtp-Source: AJdET5cjc1wf0N7Sh5SK/+75LhUV4WRuzuHKqZy8Zy3EZ68VoXHh9O2/IBOrkd7DdDQFyB7szThjWg==
X-Received: by 2002:a62:401:: with SMTP id 1-v6mr1838321pfe.156.1542046608629;
        Mon, 12 Nov 2018 10:16:48 -0800 (PST)
Received: from [192.168.32.39] ([64.114.255.114])
        by smtp.gmail.com with ESMTPSA id 128-v6sm18641043pfd.64.2018.11.12.10.16.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 10:16:47 -0800 (PST)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: NULL dereference in rpcauth_lookup_credcache
From:   Chuck Lever <chucklever@gmail.com>
In-Reply-To: <c986450a2d19fa796078ed51b9d0fb8a79eda696.camel@hammerspace.com>
Date:   Mon, 12 Nov 2018 10:16:46 -0800
Cc:     Bruce Fields <bfields@fieldses.org>,
        "schumakeranna@gmail.com" <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <BA9BDDF8-DC35-4D6D-9424-6A3BBF2799D9@gmail.com>
References: <20181108214452.GH6090@fieldses.org>
 <04114B00-B5A8-4F8A-B052-A266AED7725D@gmail.com>
 <20181110214939.GA16755@fieldses.org>
 <c986450a2d19fa796078ed51b9d0fb8a79eda696.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 12, 2018, at 9:59 AM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Sat, 2018-11-10 at 16:49 -0500, Bruce Fields wrote:
>> Looks like it's the fault of
>>=20
>> 07d02a67b7faae "SUNRPC: Simplify lookup code"
>=20
> I'm having trouble reproducing this bug. I've tried both cthon and
> xfstests in a loop, so far without success (both NFSv3 and v4.1, but
> only sec=3Dsys). Is there anything else you're doing that I might try?
>=20
> e.g. Are you running multiple workloads in parallel? Different =
users?..

Some observations, for what they are worth:

Single user test running with no other NFS workload.

I see the BUG fire at umount time, not during the test.

My client is a two-node NUMA system with 12 cores, which
could be more likely to trigger races.

Export is tmpfs.


>> --b.
>>=20
>> On Fri, Nov 09, 2018 at 01:01:30PM -0500, Chuck Lever wrote:
>>>=20
>>>> On Nov 8, 2018, at 4:44 PM, J. Bruce Fields <bfields@fieldses.org
>>>>> wrote:
>>>>=20
>>>> Since -rc1 my regression tests crash my client.  Is this a known
>>>> problem?  I'll investigate some more, I haven't even looked at
>>>> the code
>>>> yet or checked which test exactly is hitting this.
>>>>=20
>>>> --b.
>>>>=20
>>>> [  164.109570] BUG: unable to handle kernel NULL pointer
>>>> dereference at 0000000000000008
>>>> [  164.111207] PGD 0 P4D 0=20
>>>> [  164.111528] Oops: 0000 [#1] PREEMPT SMP PTI
>>>> [  164.112303] CPU: 2 PID: 2947 Comm: kworker/u8:5 Not tainted
>>>> 4.20.0-rc1-13223-gafb6d1c474ef #1898
>>>> [  164.113487] Hardware name: QEMU Standard PC (i440FX + PIIX,
>>>> 1996), BIOS ?-20180531_142017-buildhw-08.phx2.fedoraproject.org-
>>>> 1.fc28 04/01/2014
>>>> [  164.115301] Workqueue: rpciod rpc_async_schedule [sunrpc]
>>>> [  164.115920] RIP: 0010:rpcauth_lookup_credcache+0x3d/0x450
>>>> [sunrpc]
>>>> [  164.116700] Code: 89 f5 41 54 41 89 d4 53 48 83 ec 38 89 4d b0
>>>> 4c 8b 7f 20 65 48 8b 04 25 28 00 00 00 48 89 45 d0 31 c0 48 8d 45
>>>> c0 48 89 45 c8 <41> 8b 77 08 48 89 45 c0 48 8b 47 10 4c 89 ef 48
>>>> 8b 40 28 e8 cb d2
>>>> [  164.119299] RSP: 0018:ffffc90001ee3cf0 EFLAGS: 00010246
>>>> [  164.119872] RAX: ffffc90001ee3d10 RBX: ffff88007cc18180 RCX:
>>>> 0000000000600040
>>>> [  164.120800] RDX: 0000000000000001 RSI: ffffc90001ee3d60 RDI:
>>>> ffff88007cafb198
>>>> [  164.121643] RBP: ffffc90001ee3d50 R08: 0000000000000000 R09:
>>>> 0000000000000000
>>>> [  164.122464] R10: 0000000000000000 R11: 0000000000000000 R12:
>>>> 0000000000000001
>>>> [  164.123373] R13: ffffc90001ee3d60 R14: ffff88007cafb198 R15:
>>>> 0000000000000000
>>>> [  164.124296] FS:  0000000000000000(0000)
>>>> GS:ffff88007fd00000(0000) knlGS:0000000000000000
>>>> [  164.125322] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>>> [  164.126006] CR2: 0000000000000008 CR3: 000000007829c003 CR4:
>>>> 00000000001606e0
>>>> [  164.126860] Call Trace:
>>>> [  164.127045]  ? call_retry_reserve+0x30/0x30 [sunrpc]
>>>> [  164.127622]  rpcauth_lookupcred+0xa0/0xc0 [sunrpc]
>>>> [  164.128200]  rpcauth_refreshcred+0x15f/0x170 [sunrpc]
>>>> [  164.128807]  __rpc_execute+0xa9/0x460 [sunrpc]
>>>> [  164.129281]  process_one_work+0x227/0x630
>>>> [  164.129684]  worker_thread+0x3c/0x390
>>>> [  164.130062]  ? process_one_work+0x630/0x630
>>>> [  164.130609]  kthread+0x11d/0x140
>>>> [  164.130936]  ? kthread_park+0x80/0x80
>>>> [  164.131339]  ret_from_fork+0x3a/0x50
>>>> [  164.131676] Modules linked in: rpcsec_gss_krb5 nfsv4 nfs lockd
>>>> grace auth_rpcgss sunrpc
>>>> [  164.132719] CR2: 0000000000000008
>>>> [  164.133050] ---[ end trace b4028a6781a696ad ]---
>>>>=20
>>>=20
>>> I just encountered this repeatedly with cthon04 general tests.
>>>=20
>>> MNTOPTIONS=3D"rw,proto=3Dtcp,vers=3D4.1,sec=3Dsys"
>>>=20
>>>=20
>>> --
>>> Chuck Lever
>>> chucklever@gmail.com
>>>=20
>>>=20
> --=20
> Trond Myklebust
> CTO, Hammerspace Inc
> 4300 El Camino Real, Suite 105
> Los Altos, CA 94022
> www.hammer.space

--
Chuck Lever
chucklever@gmail.com



