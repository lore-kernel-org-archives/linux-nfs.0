Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58220 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751763AbdEJIFV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 10 May 2017 04:05:21 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAOssrKdKmhUZtDja+SqHy_wPreyvE=oi90E+_uR_KPCOE-iHnw@mail.gmail.com>
References: <CAOssrKdKmhUZtDja+SqHy_wPreyvE=oi90E+_uR_KPCOE-iHnw@mail.gmail.com> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk> <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com> <10943.1494284264@warthog.procyon.org.uk> <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com> <15762.1494322915@warthog.procyon.org.uk> <CAOssrKeR4bNwYyuwyr2d5fG8RcxeyWKREFTdnGqovus9t_2n4A@mail.gmail.com> <1494355884.2659.18.camel@redhat.com>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: dhowells@redhat.com, Jeff Layton <jlayton@redhat.com>,
        viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 10 May 2017 09:05:18 +0100
Message-ID: <30059.1494403518@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi <mszeredi@redhat.com> wrote:

> And the static string thing that David implemented is also a very good
> idea, IMO.

There is an issue with it: it's fine as long as you keep a ref on the module
that generated it or clear all strings as part of module removal (which the
mount context in this patchset does).  With the NFS mount context I did, I
have to keep a ref on the NFS protocol module as well as the NFS filesystem
module.

I'm tempted to make it conditionally copy the string using kvasprintf_const()
- which would also permit format substitution.

David
