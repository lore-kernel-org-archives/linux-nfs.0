Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34383 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946373AbcJaUal (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2016 16:30:41 -0400
Received: by mail-qk0-f196.google.com with SMTP id o68so7738795qkf.1
        for <linux-nfs@vger.kernel.org>; Mon, 31 Oct 2016 13:30:40 -0700 (PDT)
Subject: Re: [PATCH] NFSv41: fix NULL dereference in nfs40_setup_sequence
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=utf-8
From: Vitaliy Gusev <gusev.vitaliy@gmail.com>
In-Reply-To: <4E199BAA-DBDF-42CE-8B26-AF9787467796@primarydata.com>
Date: Mon, 31 Oct 2016 23:30:35 +0300
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Schumaker Anna <anna.schumaker@netapp.com>
Message-Id: <6792CF54-FC7B-4287-B698-5FDD19CF7C69@gmail.com>
References: <0A7143CE-0592-444D-BA53-9CBB33E4373F@gmail.com> <5D2E82C6-FBF5-4590-B674-B6C904CBB449@primarydata.com> <9CC2D174-84E5-4820-B6B7-AC885753AC91@gmail.com> <4E199BAA-DBDF-42CE-8B26-AF9787467796@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On 31 Oct 2016, at 20:54, Trond Myklebust <trondmy@primarydata.com> =
wrote:
>=20
>>=20
>> On Oct 31, 2016, at 13:31, Vitaliy Gusev <gusev.vitaliy@gmail.com> =
wrote:
>> Do you like to get crash every time a remote side sends improper =
datas? I believe not.
>=20
> There are a million other ways to screw a client over if your server =
is buggy or compromised.

I agree, but crashes are not right way to work with incorrect datas and =
that=E2=80=99s why I reported problem.=20


>>=20
>> I proposed just ignore the flag OPEN4_RESULT_CONFIRM  for nfs4.1+ =
clients.
>> RFC5661 has description that allows a client to do that:
>>=20
>>  o  OPEN4_RESULT_CONFIRM is deprecated and MUST NOT be returned by an
>>      NFSv4.1 server.
>=20
> I know what the spec says. The point is that the client will leak =
memory, and fail to handle the situation correctly when the server =
returns OPEN4_RESULT_CONFIRM with or with the patch that you are =
proposing.
> The right thing to do here would rather be to print out a big fat =
warning to the user, and then possibly also to kill the mount.

That=E2=80=99s a good point. What if return error for OPEN operation =
instead of kill the mount?

=E2=80=94=E2=80=94=E2=80=94
Thanks,
Vitaliy Gusev


---
Vitaliy Gusev


