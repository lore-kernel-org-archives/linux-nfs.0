Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:35626 "EHLO
        mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751419AbdEJNd5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 May 2017 09:33:57 -0400
Received: by mail-yw0-f176.google.com with SMTP id l135so15563113ywb.2
        for <linux-nfs@vger.kernel.org>; Wed, 10 May 2017 06:33:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOssrKeyUGCbAORH0ySA2WRBn7jLmPPNEBvvvyb0xMf67KsuCg@mail.gmail.com>
References: <CAOssrKdKmhUZtDja+SqHy_wPreyvE=oi90E+_uR_KPCOE-iHnw@mail.gmail.com>
 <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
 <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com>
 <10943.1494284264@warthog.procyon.org.uk> <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com>
 <15762.1494322915@warthog.procyon.org.uk> <CAOssrKeR4bNwYyuwyr2d5fG8RcxeyWKREFTdnGqovus9t_2n4A@mail.gmail.com>
 <1494355884.2659.18.camel@redhat.com> <30059.1494403518@warthog.procyon.org.uk>
 <1494422409.2688.13.camel@redhat.com> <CAOssrKeyUGCbAORH0ySA2WRBn7jLmPPNEBvvvyb0xMf67KsuCg@mail.gmail.com>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Wed, 10 May 2017 15:33:56 +0200
Message-ID: <CAOssrKeJis7En48+c2rbxj5FVQgnrfB7ucmwfe55jDW_tttytQ@mail.gmail.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
To: Jeff Layton <jlayton@redhat.com>
Cc: David Howells <dhowells@redhat.com>,
        viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> That's why I liked the static string thing.  It's just one assignment
> and no worries about freeing.  Not sure what to do about modules,
> though.  Can we somehow move the cost of checking the validity to the
> place where the error is retrieved?

I'm thinking along the lines of not allowing module virtual addresses
to be recycled after module remove...

Thanks,
Miklos
