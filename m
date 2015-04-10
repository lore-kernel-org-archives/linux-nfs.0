Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f42.google.com ([209.85.216.42]:37524 "EHLO
	mail-vn0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbbDJSp2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Apr 2015 14:45:28 -0400
Received: by vnbg129 with SMTP id g129so7652367vnb.4
        for <linux-nfs@vger.kernel.org>; Fri, 10 Apr 2015 11:45:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALs61uewbb28BcZ=d_qaYWtvUt5-xLGkn1uMXWhpjb_38f8ZtQ@mail.gmail.com>
References: <CALs61ueTJ4_WT00Sqz5TKzhkbrS32UjcQ0zVw6B8ikahE4Rhcw@mail.gmail.com>
	<CAHQdGtSbn643SVAZ2Y_VzxmS_b-9=+pqPGWGoHtt25hpHpygLw@mail.gmail.com>
	<CALs61uewbb28BcZ=d_qaYWtvUt5-xLGkn1uMXWhpjb_38f8ZtQ@mail.gmail.com>
Date: Fri, 10 Apr 2015 14:45:26 -0400
Message-ID: <CAHQdGtSZcNj40YFYbKVL7M5ZtBgD278e6ifqM1hpb6BadU4j5A@mail.gmail.com>
Subject: Re: Problems mounting via UDP from a netapp with multiple interfaces
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Gregory Boyce <gregory.boyce@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 9, 2015 at 9:20 PM, Gregory Boyce <gregory.boyce@gmail.com> wrote:
> On Thu, Apr 9, 2015, 8:23 PM Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>
> On Thu, Apr 9, 2015 at 3:34 PM, Gregory Boyce <gregory.boyce@gmail.com>
> wrote:
>> Folks,
>>
>> I've been encountering a problem with NFS clients attempting to mount
>> from a netapp via UDP where the netapp is responding on the wrong
>> interface.  On some of our older systems, this mount worked properly,
>> while on newer systems nfs-utils ends up failing the mount.  Mounting
>> via TCP works fine.
>
>
> This is a server bug.. Those are not fixable on the client.
>
> Trond
>
>
>
> Since the clients are successfully mounting the filers right now with much
> older client software, it seems to me that it can at least be worked around
> on the client side.
>

No. You are not supposed to be able to work around security issues,
and it is indeed a security issue when a client gets a reply from an
IP address that it does not recognise as being the same as the one it
sent an RPC to.

NetApp is aware of this bug, and has had burts open for it for at
least a decade now. Have you tried contacting them for a fix?

Trond
