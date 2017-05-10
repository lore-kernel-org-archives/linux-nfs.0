Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:36663 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752959AbdEJNhV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 May 2017 09:37:21 -0400
Received: by mail-qk0-f182.google.com with SMTP id u75so29865324qka.3
        for <linux-nfs@vger.kernel.org>; Wed, 10 May 2017 06:37:21 -0700 (PDT)
Message-ID: <1494423438.2688.15.camel@redhat.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
From: Jeff Layton <jlayton@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: Miklos Szeredi <mszeredi@redhat.com>,
        viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Date: Wed, 10 May 2017 09:37:18 -0400
In-Reply-To: <25115.1494423114@warthog.procyon.org.uk>
References: <1494422409.2688.13.camel@redhat.com>
         <CAOssrKdKmhUZtDja+SqHy_wPreyvE=oi90E+_uR_KPCOE-iHnw@mail.gmail.com>
         <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
         <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
         <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com>
         <10943.1494284264@warthog.procyon.org.uk>
         <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com>
         <15762.1494322915@warthog.procyon.org.uk>
         <CAOssrKeR4bNwYyuwyr2d5fG8RcxeyWKREFTdnGqovus9t_2n4A@mail.gmail.com>
         <1494355884.2659.18.camel@redhat.com>
         <30059.1494403518@warthog.procyon.org.uk>
         <25115.1494423114@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-05-10 at 14:31 +0100, David Howells wrote:
> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > One idea might be to always kfree it on syscall entry
> 
> You can't do that otherwise there's no way to retrieve the strings.
> 
> 

True...you'd have to exempt the syscall that does the retrieving.
-- 
Jeff Layton <jlayton@redhat.com>
