Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:48614 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485Ab1ECGzQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2011 02:55:16 -0400
Received: by iyb14 with SMTP id 14so5257244iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 02 May 2011 23:55:15 -0700 (PDT)
In-Reply-To: <1304373764.23069.17.camel@lade.trondhjem.org>
References: <BANLkTi=X0VtcSecmEwzPBTqk3L154aj+2Q@mail.gmail.com>
	<20110502140750.GA10885@fieldses.org>
	<BANLkTinTu8XVmxkUUhJby8=DNY4sZF5VAQ@mail.gmail.com>
	<1304347155.7830.7.camel@lade.trondhjem.org>
	<BANLkTikZnnt0cmpP4iT4Q4EJTxZnSC_SYQ@mail.gmail.com>
	<1304356699.7830.26.camel@lade.trondhjem.org>
	<BANLkTi=2uYagwN=Xy9FxhXV4wt3tf669JA@mail.gmail.com>
	<1304367673.20876.1.camel@lade.trondhjem.org>
	<BANLkTimB=-QaW8S-H9XNv9TM+gWbB23CjQ@mail.gmail.com>
	<1304373764.23069.17.camel@lade.trondhjem.org>
Date: Tue, 3 May 2011 08:55:15 +0200
Message-ID: <BANLkTinqn6=UJdF3H+seTskuk5JRtW9-kg@mail.gmail.com>
Subject: Re: How does NFS handle notify?
From: Stef Bon <stefbon@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

2011/5/3 Trond Myklebust <Trond.Myklebust@netapp.com>:

> You've proposed a 'solution', but I'm still not seeing what the problem
> is.
>
>     1. Why do we need to develop kernel support for dnotify+inotify+...
>        in every networked filesystem + fuse?

Well yes that's a problem indeed. I see also there are more different
types, which do not make life easier.

>     2. What are the killer app use cases that we need to support and
>        that cannot be supported with existing methods?
>

I do not have one, only the idea that Linux in general will benefit,
when notify is supported for users using cifs, nfs and fuse fs's like
mine.

> Notifications on large distributed filesystems are a scalability
> nightmare (particularly so for inotify), so they need careful
> justification and need to be limited in scope. Just pulling out a
> solution from your magic hat isn't sufficient.

I do not have much experience with large distributed filesystems (can
you name an example?) but isn't it possible to just turn notify off
for such systems?

Stef
