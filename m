Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:62796 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbaHMHpq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2014 03:45:46 -0400
MIME-Version: 1.0
In-Reply-To: <53EA4450.1060900@RedHat.com>
References: <1407326472-13853-1-git-send-email-pshilovsky@samba.org>
	<1407326472-13853-6-git-send-email-pshilovsky@samba.org>
	<53EA4450.1060900@RedHat.com>
Date: Wed, 13 Aug 2014 11:45:45 +0400
Message-ID: <CAKywueR2u+RFGP7_2FX427H5Z8Q_0i4LQJAZqTUZG4p=wMMz9g@mail.gmail.com>
Subject: Re: [PATCH 5/5] special: fix op_unlk and op_ren tests output
From: Pavel Shilovsky <pshilovsky@samba.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-cifs <linux-cifs@vger.kernel.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@samba.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2014-08-12 20:44 GMT+04:00 Steve Dickson <SteveD@redhat.com>:
> Hello,
>
> Just curious... what is wrong with the output of these
> two tests?

These tests call 'ls' command for the path names that doesn't exists -
".nfs*". Previously we create file names through "tempnam(".",
"nfsa")" command and have "nfs*" style file names (without the first
dot symbol). So, the proposed patch fixes the output in the way we
already have in op_chmod.c.

-- 
Best regards,
Pavel Shilovsky.
