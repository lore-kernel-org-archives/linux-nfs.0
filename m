Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35719 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752631AbdHKOS0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Aug 2017 10:18:26 -0400
Received: by mail-it0-f66.google.com with SMTP id 76so3737863ith.2
        for <linux-nfs@vger.kernel.org>; Fri, 11 Aug 2017 07:18:26 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] nfs/flexfiles: fix leak of nfs4_ff_ds_version arrays
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <435422355.5999768.1501765030094.JavaMail.zimbra@desy.de>
Date: Fri, 11 Aug 2017 10:18:23 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <19806192-AF74-4091-BB63-FF41A7687B7F@monkey.org>
References: <20170801202501.4876-1-dros@primarydata.com>
 <A49F4A5C-4101-4D60-A14F-FC20D4F53897@monkey.org>
 <435422355.5999768.1501765030094.JavaMail.zimbra@desy.de>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Tigran,

I don't think so, this fixes a simple memory leak where memory is not =
freed and nothing holds a reference to it. It should not lead to any =
invalid pointers, but will eventually lead to the OOM killer killing a =
bunch of processes.

There have been other recent changes that may have addressed this. Can =
you reproduce with the latest changes?

-dros

> On Aug 3, 2017, at 8:57 AM, Mkrtchyan, Tigran =
<tigran.mkrtchyan@desy.de> wrote:
>=20
> Hi Dros,
>=20
> can this leak be the source of issue described here:  =
http://www.spinics.net/lists/linux-nfs/msg64890.html
>=20
> Tigran.
>=20
> ----- Original Message -----
>> From: "Weston Andros Adamson" <dros@monkey.org>
>> To: "Trond Myklebust" <trond.myklebust@primarydata.com>, "Anna =
Schumaker" <anna.schumaker@netapp.com>
>> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>
>> Sent: Thursday, August 3, 2017 4:07:28 AM
>> Subject: Re: [PATCH] nfs/flexfiles: fix leak of nfs4_ff_ds_version =
arrays
>=20
>> This should probably be CCed to some stable releases too. I'll figure =
it out
>> soon.
>>=20
>> -dros
>>=20
>>> On Aug 1, 2017, at 4:25 PM, Weston Andros Adamson <dros@monkey.org> =
wrote:
>>>=20
>>> The client was freeing the nfs4_ff_layout_ds, but not the contained
>>> nfs4_ff_ds_version array.
>>>=20
>>> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
>>> ---
>>> fs/nfs/flexfilelayout/flexfilelayoutdev.c | 1 +
>>> 1 file changed, 1 insertion(+)
>>>=20
>>> diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>>> b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>>> index 6df7a0cf5660..f32c58bbe556 100644
>>> --- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>>> +++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
>>> @@ -32,6 +32,7 @@ void nfs4_ff_layout_free_deviceid(struct =
nfs4_ff_layout_ds
>>> *mirror_ds)
>>> {
>>> 	nfs4_print_deviceid(&mirror_ds->id_node.deviceid);
>>> 	nfs4_pnfs_ds_put(mirror_ds->ds);
>>> +	kfree(mirror_ds->ds_versions);
>>> 	kfree_rcu(mirror_ds, id_node.rcu);
>>> }
>>>=20
>>> --
>>> 2.11.0 (Apple Git-81)
>>>=20
>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

