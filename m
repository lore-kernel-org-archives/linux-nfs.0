Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53644 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932719AbcJGRGh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Oct 2016 13:06:37 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Matt Garman" <matthew.garman@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Kerberized NFS client and slow user write performance
Date: Fri, 07 Oct 2016 13:06:35 -0400
Message-ID: <BF6133B5-7061-4228-95FC-D2830A4FE9FF@redhat.com>
In-Reply-To: <CAJvUf-CSsxw0v5fncoM3fKxwdSp6Gv_WO3dszcz+Rjpopc77_g@mail.gmail.com>
References: <CAJvUf-CSsxw0v5fncoM3fKxwdSp6Gv_WO3dszcz+Rjpopc77_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7 Oct 2016, at 12:43, Matt Garman wrote:

> We seem to be increasingly hit by this bug:
>
> https://access.redhat.com/solutions/2040223
> "On RHEL 6 NFS client usring kerberos (krb5), one user experiences
> slow write performance, another does not"
>
> You need a RH subscription to see that in its entirety.  But the
> subject basically says it all: randomly, one or more users will be
> subjected to *terrible* NFS write performance that persists until
> reboot.
>
> There is a root cause shown, but that is cryptic to non-kernel devs;
> it doesn't explain from a user perspective what triggers this state.
> (That's why it appears to be random to me.)
>
> There is no solution or workaround given.  This appears to be on a
> per-user + per-server basis, so a crude workaround is to migrate the
> user to a different server.  And we do regular reboots, which somewhat
> hides the problem.
>
> Does this bug also exist in upstream (i.e. non distro specific Linux
> NFS code)?  If so, is there any more detail on it, and/or a fix?

Hi Matt, a fix for this problem went in upstream:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ce52914eb76efd62aa48d738cf845b37852bf920
which landed in 4.8.

I expect this will get fixed in RHEL6 and RHEL7 shortly, though I don't 
have
any BZ numbers handy..  let me know directly if you need them.

Ben
