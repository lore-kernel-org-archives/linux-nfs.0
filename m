Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:49722 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932280AbcIFSQm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Sep 2016 14:16:42 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Fields Bruce James <bfields@fieldses.org>
CC: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/5] Fix callback channel handling of referring triples
Date: Tue, 6 Sep 2016 18:16:37 +0000
Message-ID: <A8E38AF7-2C2E-4160-92EE-2C8B4EC0A733@primarydata.com>
References: <1472422865-28698-1-git-send-email-trond.myklebust@primarydata.com>
 <20160906181453.GA29563@fieldses.org>
In-Reply-To: <20160906181453.GA29563@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 6, 2016, at 14:14, J. Bruce Fields <bfields@fieldses.org> wrote:
>=20
> On Sun, Aug 28, 2016 at 06:21:00PM -0400, Trond Myklebust wrote:
>> RFC5661 has a mechanism for ensuring that the forward channel and backwa=
rd
>> channel do not race. The Linux client implements this mechanism, but in
>> a manner that is racy, making it rather pointless, and buggy (Oops!).
>>=20
>> This patch series fixes the most egregious issues around delegations and
>> layouts by ensuring that we wait for completion of the actual setup of
>> the delegation or layout that could be subject to recall.
>=20
> Out of curiosity--so do we know if there are servers out there using
> it at this point?

Yes, the Primary Data server does.

>=20
> --b.
>=20
>>=20
>> Trond Myklebust (5):
>>  NFSv4.1: Fix Oopsable condition in server callback races
>>  NFSv4.1: Delay callback processing when there are referring triples
>>  NFSv4.1: Defer bumping the slot sequence number until we free the slot
>>  NFSv4.1: Close callback races for OPEN, LAYOUTGET and LAYOUTRETURN
>>  NFSv4.1: Remove obsolete and incorrrect assignment in
>>    nfs4_callback_sequence
>>=20
>> fs/nfs/callback_proc.c |  8 ++---
>> fs/nfs/nfs4proc.c      | 89 +++++++++++++++++++++++++++++++++++++++++---=
------
>> fs/nfs/nfs4session.c   | 53 ++++++++++++++++++++++++++++++
>> fs/nfs/nfs4session.h   |  7 +++-
>> 4 files changed, 135 insertions(+), 22 deletions(-)
>>=20
>> --=20
>> 2.7.4
>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

