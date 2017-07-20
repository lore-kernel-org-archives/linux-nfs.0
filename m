Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:63468 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965453AbdGTUOM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Jul 2017 16:14:12 -0400
Content-Type: text/plain; charset=utf-8
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3 1/1] PNFS fix dangling DS mount
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <1500580582.5457.1.camel@primarydata.com>
Date: Thu, 20 Jul 2017 16:14:01 -0400
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-ID: <4C765F1F-4958-4D1B-922A-95AE9CB69288@netapp.com>
References: <20170630195201.95597-1-kolga@netapp.com>
 <1500580582.5457.1.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 20, 2017, at 3:56 PM, Trond Myklebust <trondmy@primarydata.com> =
wrote:
>=20
> Hi Olga,
>=20
> Apologies for missing this patch. It was hiding in my 'linux-fsdevel'
> mailbox, so I didn't recognise it as a NFS patch.
>=20

Yeah after I mailed it out I realized I cc-ed fsdevel incorrectly.

> On Fri, 2017-06-30 at 15:52 -0400, Olga Kornievskaia wrote:
>> There is a regression by commit 8d40b0f14846 ("NFS filelayout:call
>> GETDEVICEINFO after pnfs_layout_process completes"). It leaves the
>> DS mount dangling.
>>=20
>> Previously, filelayout_alloc_sec() would call
>> filelayout_check_layout()
>> which would call nfs4_find_get_deviceid which ups the count on the
>> device_id. It's only called once and it's matched by the
>> filelayout_free_lseg() that calls nfs4_fl_put_deviceid().
>>=20
>> After that patch, each read/write ends up calling
>> nfs4_find_get_deviceid
>> and there is no balance for that. Instead, do nfs4_fl_put_deviceid()
>> in the filelayout's .pg_cleanup and remove it from
>> filelayout_free_lseg.
>>=20
>> But we still need a reference to hold over the lifetime of the
>> segment.
>> For every new lseg that's created we need to take a reference on
>> deviceid
>> that uses it. It will be released in the "free_lseg" routine.
>=20
> This is what I'm not understanding. If you have a reference in the
> layout segment, then why do you need to call nfs4_find_get_deviceid()
> in the read/write code?

I think I=E2=80=99m probably misunderstanding the question. It sounds to =
me that you asking me for why the commit 8d40b0f14846 was done the way =
it was done (I=E2=80=99d would say it was done as per your suggestion).

I would say the call to nfs4_find_get_deviceid() has always been in the =
read/write code. It was a part of the pnfs_update_layout() but the =
commit 8d40b0f14846 moved it out of it (so that the layoutget was =
complete) and then the call to the getdeviceinfo would be done.=20

> Isn't it sufficient to change the "pg_init" calls to check whether or
> not the struct nfs4_filelayout_segment has set a value for dsaddr =
(that
> needs to be done with care to avoid races - cmpxchg() is your friend),
> and then rely on that reference being set for the remainder of the
> layout segment lifetime?

Are you suggesting to change when getdeviceinfo is suppose to be called?

>=20
>=20
> --=20
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com

