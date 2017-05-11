Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45936 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934420AbdEKOar (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 May 2017 10:30:47 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAMp4zn_rhfzmy-J6Y_nL-HR+BmVpYMLFGqPNEzpm93HXTM7cDQ@mail.gmail.com>
References: <CAMp4zn_rhfzmy-J6Y_nL-HR+BmVpYMLFGqPNEzpm93HXTM7cDQ@mail.gmail.com> <149443309780.2378.6532276992468576087.stgit@warthog.procyon.org.uk> <149443316786.2378.6065648057770350840.stgit@warthog.procyon.org.uk>
To: Sargun Dhillon <sargun@sargun.me>
Cc: dhowells@redhat.com, mszeredi@redhat.com, viro@zeniv.linux.org.uk,
        jlayton@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 07/14] Implement fsopen() to prepare for a mount
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 11 May 2017 15:30:34 +0100
Message-ID: <6167.1494513034@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sargun Dhillon <sargun@sargun.me> wrote:

> Instead of string based configuration, does it perhaps make sense to
> pass in structured mount data? Something like:

I don't think it helps particularly.

> enum mount_command_id {
>     MOUNT_OPTION_STR,
>     MOUNT_SET_USER_NS
> };
> 
> struct mount_attr {
>    __u64 command_id;
>    union {
>        char option_str[4095];
>        char mount_source[PATH_MAX];

Why limit the option size to 4096?  I can see situations where it might be
necessary to hand in a bigger blob - giving cifs a Microsoft Kerberos PAC for
example.

>        struct {
>            __u32 user_ns_fd

There are more than just that namespace that could be relevant.

>        }
>    }
> }
> 
> It seems a lot less error prone to me.

Not really.  The only real difference is how one selects what action is
intended and how one determines the length.  write() has a length parameter.

David
