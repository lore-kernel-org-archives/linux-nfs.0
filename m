Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f44.google.com ([209.85.216.44]:33921 "EHLO
	mail-vn0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754577AbbE1WY3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 18:24:29 -0400
Received: by vnbf129 with SMTP id f129so6444420vnb.1
        for <linux-nfs@vger.kernel.org>; Thu, 28 May 2015 15:24:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHpGcMLQGc4HUZEDRKAv2yaH7wwSBBO_jrMA6+=AQ6hb=WrNUg@mail.gmail.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<8d601ee8babe5239b7926542c713c58502b15e35.1429868795.git.agruenba@redhat.com>
	<20150528203332.GD31663@fieldses.org>
	<CAHQdGtTe9RfxxGU+UzxnT8A1BmhtPQaOB=g6wXpvmHTu6Ho=Jg@mail.gmail.com>
	<CAHpGcM+=ydzFDeTc4_1F9dYbtJ+D_mGVLKZOYkvvRjT7ZHd_xA@mail.gmail.com>
	<CAHQdGtQKRokdRRuGmU-qD3fxOUE8cYrtb=sNcYenVT8M8XAmYA@mail.gmail.com>
	<CAHQdGtRaq93Rk1ZNn7tqBPJVWhWwUGS7k1XzdC3etfna4kLtDg@mail.gmail.com>
	<CAHpGcMLQGc4HUZEDRKAv2yaH7wwSBBO_jrMA6+=AQ6hb=WrNUg@mail.gmail.com>
Date: Thu, 28 May 2015 18:24:28 -0400
Message-ID: <CAHQdGtRzV0VKAYPEjeoxBHVqnV4330omE5mJjCn2WDG-DeoAZA@mail.gmail.com>
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

On Thu, May 28, 2015 at 6:09 PM, Andreas Grünbacher
<andreas.gruenbacher@gmail.com> wrote:
> 2015-05-28 23:55 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.com>:
>>> We already do this kind of check with the existing code. What's wrong with it?
>>
>> Actually, you're right, we don't check for the previous word, however
>> fixing that is a question of adding 2 extra checks in
>> decode_getfattr_attrs(), one in decode_getfattr_statfs(), and one in
>> decode_fsinfo().
>>
>> It shouldn't require a rewrite of the entire nfs4xdr.c.
>
> I would actually prefer either verifying the reply bitmap against the
> request bitmap,
> or checking the bitmap first as this patch does --- the current
> approach of knocking
> individual bits over and checking if any "before" bits have been missed isn't
> exactly what I would take as a textbook example.


...and I'd prefer that we don't keep rewriting code that works. Screw
the textbooks...

Trond
