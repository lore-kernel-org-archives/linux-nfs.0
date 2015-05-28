Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f44.google.com ([209.85.216.44]:45249 "EHLO
	mail-vn0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754735AbbE1VzZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 17:55:25 -0400
Received: by vnbg7 with SMTP id g7so6453145vnb.12
        for <linux-nfs@vger.kernel.org>; Thu, 28 May 2015 14:55:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtQKRokdRRuGmU-qD3fxOUE8cYrtb=sNcYenVT8M8XAmYA@mail.gmail.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<8d601ee8babe5239b7926542c713c58502b15e35.1429868795.git.agruenba@redhat.com>
	<20150528203332.GD31663@fieldses.org>
	<CAHQdGtTe9RfxxGU+UzxnT8A1BmhtPQaOB=g6wXpvmHTu6Ho=Jg@mail.gmail.com>
	<CAHpGcM+=ydzFDeTc4_1F9dYbtJ+D_mGVLKZOYkvvRjT7ZHd_xA@mail.gmail.com>
	<CAHQdGtQKRokdRRuGmU-qD3fxOUE8cYrtb=sNcYenVT8M8XAmYA@mail.gmail.com>
Date: Thu, 28 May 2015 17:55:24 -0400
Message-ID: <CAHQdGtRaq93Rk1ZNn7tqBPJVWhWwUGS7k1XzdC3etfna4kLtDg@mail.gmail.com>
Subject: Re: [RFC v3 36/45] NFSv4: Fix GETATTR bitmap verification
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 28, 2015 at 5:40 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Thu, May 28, 2015 at 5:05 PM, Andreas Grünbacher
> <andreas.gruenbacher@gmail.com> wrote:
>> 2015-05-28 22:50 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.com>:
>>> On Thu, May 28, 2015 at 4:33 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>>> On Fri, Apr 24, 2015 at 01:04:33PM +0200, Andreas Gruenbacher wrote:
>>>>> The NFSv4 client sends the server GETATTR requests with different sets of
>>>>> requested attributes depending on the situation.  The requested set of
>>>>> attributes is encoded in a bitmap; the server replies with the set of
>>>>> attributes it could return.  These bitmaps can be several words wide.  The
>>>>> bitmap returned by the server is a subset of the bitmap sent by the client.
>>>>>
>>>>> While decoding the reply, the client tries to verify the reply bitmap: it
>>>>> checks if any previous, unexpected attributes are left in the same word of the
>>>>> bitmap for each attribute it tries to decode, then it clears the current
>>>>> attribute's bit in the bitmap for the next decode function.
>>>>>
>>>>> The client fails to detect when unexpected attributes are sent after the last
>>>>> expected attribute in each word in the bitmap.
>>>>
>>>> Is it important that the client catch that?
>>>
>>> Right. What is the actual problem or bug that this patch is trying to
>>> fix? Why do we care if a buggy server sends us extra info that we
>>> didn't ask for?
>>
>> I think we do care to correctly decode (and reject) well-formed but illegal
>> server replies. In this case, when switching to the next word of a bitmap, the
>> client doesn't check if the previous word has been completely "consumed" yet.
>> If any attributes are "missed", decoding the attribute values gets out of sync,
>> garbage is decoded, and the error may be missed.
>>
>
> We already do this kind of check with the existing code. What's wrong with it?
>

Actually, you're right, we don't check for the previous word, however
fixing that is a question of adding 2 extra checks in
decode_getfattr_attrs(), one in decode_getfattr_statfs(), and one in
decode_fsinfo().

It shouldn't require a rewrite of the entire nfs4xdr.c.

Trond
