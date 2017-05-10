Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59538 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751267AbdEJNcC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 10 May 2017 09:32:02 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1494422409.2688.13.camel@redhat.com>
References: <1494422409.2688.13.camel@redhat.com> <CAOssrKdKmhUZtDja+SqHy_wPreyvE=oi90E+_uR_KPCOE-iHnw@mail.gmail.com> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk> <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com> <10943.1494284264@warthog.procyon.org.uk> <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com> <15762.1494322915@warthog.procyon.org.uk> <CAOssrKeR4bNwYyuwyr2d5fG8RcxeyWKREFTdnGqovus9t_2n4A@mail.gmail.com> <1494355884.2659.18.camel@redhat.com> <30059.1494403518@warthog.procyon.org.uk>
To: Jeff Layton <jlayton@redhat.com>
Cc: dhowells@redhat.com, Miklos Szeredi <mszeredi@redhat.com>,
        viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 10 May 2017 14:31:54 +0100
Message-ID: <25115.1494423114@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> wrote:

> One idea might be to always kfree it on syscall entry

You can't do that otherwise there's no way to retrieve the strings.

David
