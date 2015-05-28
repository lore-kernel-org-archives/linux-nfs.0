Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:33462 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754006AbbE1VFo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 17:05:44 -0400
MIME-Version: 1.0
In-Reply-To: <CAHQdGtTe9RfxxGU+UzxnT8A1BmhtPQaOB=g6wXpvmHTu6Ho=Jg@mail.gmail.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<8d601ee8babe5239b7926542c713c58502b15e35.1429868795.git.agruenba@redhat.com>
	<20150528203332.GD31663@fieldses.org>
	<CAHQdGtTe9RfxxGU+UzxnT8A1BmhtPQaOB=g6wXpvmHTu6Ho=Jg@mail.gmail.com>
Date: Thu, 28 May 2015 23:05:43 +0200
Message-ID: <CAHpGcM+=ydzFDeTc4_1F9dYbtJ+D_mGVLKZOYkvvRjT7ZHd_xA@mail.gmail.com>
Subject: Re: [RFC v3 36/45] NFSv4: Fix GETATTR bitmap verification
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-28 22:50 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.com>:
> On Thu, May 28, 2015 at 4:33 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> On Fri, Apr 24, 2015 at 01:04:33PM +0200, Andreas Gruenbacher wrote:
>>> The NFSv4 client sends the server GETATTR requests with different sets of
>>> requested attributes depending on the situation.  The requested set of
>>> attributes is encoded in a bitmap; the server replies with the set of
>>> attributes it could return.  These bitmaps can be several words wide.  The
>>> bitmap returned by the server is a subset of the bitmap sent by the client.
>>>
>>> While decoding the reply, the client tries to verify the reply bitmap: it
>>> checks if any previous, unexpected attributes are left in the same word of the
>>> bitmap for each attribute it tries to decode, then it clears the current
>>> attribute's bit in the bitmap for the next decode function.
>>>
>>> The client fails to detect when unexpected attributes are sent after the last
>>> expected attribute in each word in the bitmap.
>>
>> Is it important that the client catch that?
>
> Right. What is the actual problem or bug that this patch is trying to
> fix? Why do we care if a buggy server sends us extra info that we
> didn't ask for?

I think we do care to correctly decode (and reject) well-formed but illegal
server replies. In this case, when switching to the next word of a bitmap, the
client doesn't check if the previous word has been completely "consumed" yet.
If any attributes are "missed", decoding the attribute values gets out of sync,
garbage is decoded, and the error may be missed.

Andreas
