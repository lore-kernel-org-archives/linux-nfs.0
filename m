Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:61219 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830Ab3ARG3z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 01:29:55 -0500
MIME-Version: 1.0
In-Reply-To: <20130118095538.fdd0b3be90739b9fd9179b5d@canb.auug.org.au>
References: <1358441537-8672-1-git-send-email-piastry@etersoft.ru>
	<20130118095538.fdd0b3be90739b9fd9179b5d@canb.auug.org.au>
Date: Fri, 18 Jan 2013 10:29:54 +0400
Message-ID: <CAKywueQ33k3uGHP4LV=7KCq-V3D=3PEanbYTzVEnXwT0V-fXjA@mail.gmail.com>
Subject: Re: [PATCH v2 0/8] Add O_DENY* support for VFS and CIFS/NFS
From: Pavel Shilovsky <piastry@etersoft.ru>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/1/18 Stephen Rothwell <sfr@canb.auug.org.au>:
> Hi Pavel,
>
> On Thu, 17 Jan 2013 20:52:09 +0400 Pavel Shilovsky <piastry@etersoft.ru> wrote:
>>
>> This patchset adds support of O_DENY* flags for Linux fs layer. These flags can be used by any application that needs share reservations to organize a file access. VFS already has some sort of this capability - now it's done through flock/LOCK_MAND mechanis, but that approach is non-atomic. This patchset build new capabilities on top of the existing one but doesn't bring any changes into the flock call semantic.
>
> This has probably been discussed, but is Linux's leases implementation
> not sufficient?  Just wondering.

As I understand it, leases play different role: they allow to cache a
data for the particular open and then flush it when a lease break
comes. But we need to protect opens from being done if their
access/share mode is not suitable for previously done opens. E.g. if
we have already opened a file with O_RDONLY | O_DENYWRITE we can't
open it again with any of O_WRONLY, O_RDWR and O_DENYREAD flags (of
course all these things should only work if O_DENYMAND is specified
for the first and the second opens).

-- 
Best regards,
Pavel Shilovsky.
