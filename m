Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:33944 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934170AbdEKOfU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 May 2017 10:35:20 -0400
Received: by mail-qk0-f181.google.com with SMTP id k74so23952905qke.1
        for <linux-nfs@vger.kernel.org>; Thu, 11 May 2017 07:35:20 -0700 (PDT)
Message-ID: <1494513311.8853.5.camel@redhat.com>
Subject: Re: [PATCH 07/14] Implement fsopen() to prepare for a mount
From: Jeff Layton <jlayton@redhat.com>
To: David Howells <dhowells@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>
Cc: mszeredi@redhat.com, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>
Date: Thu, 11 May 2017 10:35:11 -0400
In-Reply-To: <6167.1494513034@warthog.procyon.org.uk>
References: <CAMp4zn_rhfzmy-J6Y_nL-HR+BmVpYMLFGqPNEzpm93HXTM7cDQ@mail.gmail.com>
         <149443309780.2378.6532276992468576087.stgit@warthog.procyon.org.uk>
         <149443316786.2378.6065648057770350840.stgit@warthog.procyon.org.uk>
         <6167.1494513034@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-05-11 at 15:30 +0100, David Howells wrote:
> Sargun Dhillon <sargun@sargun.me> wrote:
> 
> > Instead of string based configuration, does it perhaps make sense to
> > pass in structured mount data? Something like:
> 
> I don't think it helps particularly.
> 
> > enum mount_command_id {
> >     MOUNT_OPTION_STR,
> >     MOUNT_SET_USER_NS
> > };
> > 
> > struct mount_attr {
> >    __u64 command_id;
> >    union {
> >        char option_str[4095];
> >        char mount_source[PATH_MAX];
> 
> Why limit the option size to 4096?  I can see situations where it might be
> necessary to hand in a bigger blob - giving cifs a Microsoft Kerberos PAC for
> example.
> 
> >        struct {
> >            __u32 user_ns_fd
> 
> There are more than just that namespace that could be relevant.
> 
> >        }
> >    }
> > }
> > 
> > It seems a lot less error prone to me.
> 
> Not really.  The only real difference is how one selects what action is
> intended and how one determines the length.  write() has a length parameter.
> 

Agreed. I like the text based configuration better.

It also has another advantage: It's easy to strace the program and see
what it's doing. With an opaque blob, we'd need to teach strace how to
format the thing to be able to view it.

-- 
Jeff Layton <jlayton@redhat.com>
