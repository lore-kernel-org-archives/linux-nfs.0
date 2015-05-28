Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35762 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461AbbE1WJi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 18:09:38 -0400
MIME-Version: 1.0
In-Reply-To: <CAHQdGtRaq93Rk1ZNn7tqBPJVWhWwUGS7k1XzdC3etfna4kLtDg@mail.gmail.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<8d601ee8babe5239b7926542c713c58502b15e35.1429868795.git.agruenba@redhat.com>
	<20150528203332.GD31663@fieldses.org>
	<CAHQdGtTe9RfxxGU+UzxnT8A1BmhtPQaOB=g6wXpvmHTu6Ho=Jg@mail.gmail.com>
	<CAHpGcM+=ydzFDeTc4_1F9dYbtJ+D_mGVLKZOYkvvRjT7ZHd_xA@mail.gmail.com>
	<CAHQdGtQKRokdRRuGmU-qD3fxOUE8cYrtb=sNcYenVT8M8XAmYA@mail.gmail.com>
	<CAHQdGtRaq93Rk1ZNn7tqBPJVWhWwUGS7k1XzdC3etfna4kLtDg@mail.gmail.com>
Date: Fri, 29 May 2015 00:09:38 +0200
Message-ID: <CAHpGcMLQGc4HUZEDRKAv2yaH7wwSBBO_jrMA6+=AQ6hb=WrNUg@mail.gmail.com>
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

2015-05-28 23:55 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.com>:
>> We already do this kind of check with the existing code. What's wrong with it?
>
> Actually, you're right, we don't check for the previous word, however
> fixing that is a question of adding 2 extra checks in
> decode_getfattr_attrs(), one in decode_getfattr_statfs(), and one in
> decode_fsinfo().
>
> It shouldn't require a rewrite of the entire nfs4xdr.c.

I would actually prefer either verifying the reply bitmap against the
request bitmap,
or checking the bitmap first as this patch does --- the current
approach of knocking
individual bits over and checking if any "before" bits have been missed isn't
exactly what I would take as a textbook example.

Thanks,
Andreas
