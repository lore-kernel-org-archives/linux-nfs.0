Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:35506 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbbFZHzf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Jun 2015 03:55:35 -0400
MIME-Version: 1.0
In-Reply-To: <558C7535.9050502@samba.org>
References: <1435183040-22726-1-git-send-email-agruenba@redhat.com>
	<1435183040-22726-7-git-send-email-agruenba@redhat.com>
	<558C5D75.6050608@samba.org>
	<CAHpGcM+AwRubQqX96V3WbwLKXKTfk3YcgFG_eqG6r7cVbCTV-w@mail.gmail.com>
	<558C7535.9050502@samba.org>
Date: Fri, 26 Jun 2015 09:55:34 +0200
Message-ID: <CAHpGcM+Bf+ZhQEbKmtGhNMp2dJ8Btha7_gLi0Tu+Uk-zyCpQjg@mail.gmail.com>
Subject: Re: [RFC v4 06/31] richacl: In-memory representation and helper functions
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "Stefan (metze) Metzmacher" <metze@samba.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API Mailing List <linux-api@vger.kernel.org>,
        samba-technical <samba-technical@lists.samba.org>,
        linux-security-module@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-06-25 23:40 GMT+02:00 Stefan (metze) Metzmacher <metze@samba.org>:
>>> I'm wondering if the size of an ace should be dynamic,
>>> which might make it possible to support other ace types
>>> in future. E.g. supporting other identities like 128-bit values
>>> to make it easier to map Windows SIDS.
>>
>> I'm working on additionally supporting unmapped user@domain and
>> group@domain identifier strings; we have to deal with that case in the
>> nfs client; that may be useful for Samba as well.
>
> Can this be any string? So would
> "S-1-5-21-4052121579-2079768045-1474639452-1001" also work?

I don't see why not, we'd just need to prevent namespace clashes.

> How would the current thread/process get a "token" that would match such
> an ace?

Solaris seems to solve this by what they call ephemeral ids; that concept may
become useful.

> [...]
> In general shouldn't kuid_t uid = current_fsuid(); be at the top of the
> function just once?

It really is just a pointer dereference.

Thanks,
Andreas
