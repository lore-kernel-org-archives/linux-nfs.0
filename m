Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:33186 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944994AbcJaRbL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2016 13:31:11 -0400
Received: by mail-qt0-f173.google.com with SMTP id p16so77740400qta.0
        for <linux-nfs@vger.kernel.org>; Mon, 31 Oct 2016 10:31:11 -0700 (PDT)
Subject: Re: [PATCH] NFSv41: fix NULL dereference in nfs40_setup_sequence
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=utf-8
From: Vitaliy Gusev <gusev.vitaliy@gmail.com>
In-Reply-To: <5D2E82C6-FBF5-4590-B674-B6C904CBB449@primarydata.com>
Date: Mon, 31 Oct 2016 20:31:07 +0300
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Schumaker Anna <anna.schumaker@netapp.com>
Message-Id: <9CC2D174-84E5-4820-B6B7-AC885753AC91@gmail.com>
References: <0A7143CE-0592-444D-BA53-9CBB33E4373F@gmail.com> <5D2E82C6-FBF5-4590-B674-B6C904CBB449@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On 31 Oct 2016, at 18:46, Trond Myklebust <trondmy@primarydata.com> =
wrote:
>=20
>=20
>> On Oct 30, 2016, at 21:18, Vitaliy Gusev <gusev.vitaliy@gmail.com> =
wrote:
>>=20
>> Hi.
>>=20
>> During some tests I=E2=80=99ve seen nfs-client crashes. It was just =
reading file via NFSv4.1 protocol.=20
>>=20
>> The panic message is below,  fixing patch is attached.
>=20
> Why does this need to be fixed on the client? It looks like a server =
bug=E2=80=A6 In any case, the fix you propose is going to leave the =
client with broken open state.

Do you like to get crash every time a remote side sends improper datas? =
I believe not.

I proposed just ignore the flag OPEN4_RESULT_CONFIRM  for nfs4.1+ =
clients.
RFC5661 has description that allows a client to do that:

   o  OPEN4_RESULT_CONFIRM is deprecated and MUST NOT be returned by an
       NFSv4.1 server.

=E2=80=94=E2=80=94=E2=80=94

Thanks,
Vitaliy Gusev

