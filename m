Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:34406 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbbDJTEh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Apr 2015 15:04:37 -0400
Received: by iedfl3 with SMTP id fl3so28100403ied.1
        for <linux-nfs@vger.kernel.org>; Fri, 10 Apr 2015 12:04:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSZcNj40YFYbKVL7M5ZtBgD278e6ifqM1hpb6BadU4j5A@mail.gmail.com>
References: <CALs61ueTJ4_WT00Sqz5TKzhkbrS32UjcQ0zVw6B8ikahE4Rhcw@mail.gmail.com>
	<CAHQdGtSbn643SVAZ2Y_VzxmS_b-9=+pqPGWGoHtt25hpHpygLw@mail.gmail.com>
	<CALs61uewbb28BcZ=d_qaYWtvUt5-xLGkn1uMXWhpjb_38f8ZtQ@mail.gmail.com>
	<CAHQdGtSZcNj40YFYbKVL7M5ZtBgD278e6ifqM1hpb6BadU4j5A@mail.gmail.com>
Date: Fri, 10 Apr 2015 15:04:36 -0400
Message-ID: <CALs61udukSrCsDYTyohSQdwbtcvvW672=+Qyit56iTE3qViSSw@mail.gmail.com>
Subject: Re: Problems mounting via UDP from a netapp with multiple interfaces
From: Gregory Boyce <gregory.boyce@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 10, 2015 at 2:45 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> No. You are not supposed to be able to work around security issues,
> and it is indeed a security issue when a client gets a reply from an
> IP address that it does not recognise as being the same as the one it
> sent an RPC to.

"Working around" security issues is a rather common and accepted
practice when there are mitigating controls in place.  It's never a
black and white world.

> NetApp is aware of this bug, and has had burts open for it for at
> least a decade now. Have you tried contacting them for a fix?

My team is entirely involved in the client side.  I'll see what
options the team responsible for the filer have there.

-- 
Greg
