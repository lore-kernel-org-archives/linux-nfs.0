Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:34087 "EHLO
        mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752383AbcJ2Jio (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 29 Oct 2016 05:38:44 -0400
Received: by mail-vk0-f41.google.com with SMTP id x186so13619420vkd.1
        for <linux-nfs@vger.kernel.org>; Sat, 29 Oct 2016 02:38:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1477686228-12158-1-git-send-email-bfields@redhat.com>
References: <1477686228-12158-1-git-send-email-bfields@redhat.com>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Sat, 29 Oct 2016 11:38:43 +0200
Message-ID: <CAHc6FU5i3aDDNUKLUot9B8hjbiMxFR4nipB3b-ROa9k4a6KhPQ@mail.gmail.com>
Subject: Re: [PATCH 0/2] NFSv4.2 umask support
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 28, 2016 at 10:23 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
>
> The following patches allow the umask to be ignored in the presence of
> inheritable NFSv4 ACLs.  Otherwise inheritable ACLs can be rendered
> mostly useless whenever the umask masks out group bits.
>
> This solves a problem we've seen complaints about for some time, both
> upstream and from RHEL users.
>
> The new protocol has been discussed in the IETF working group and is
> documented at:
>
>         https://tools.ietf.org/html/draft-ietf-nfsv4-umask-02
>
> It's unlikely that we'll discover problems requiring an incompatible
> change, so I think we should consider this for 4.10.

Nope, these patches don't implement draft-ietf-nfsv4-umask-02 yet, and
need updating first.

Thanks,
Andreas
