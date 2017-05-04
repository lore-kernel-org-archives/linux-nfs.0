Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60478 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932601AbdEDJ1I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 May 2017 05:27:08 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1493835998.22125.15.camel@perches.com>
References: <1493835998.22125.15.camel@perches.com> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk> <1493835238.3180.7.camel@poochiereds.net>
To: Joe Perches <joe@perches.com>
Cc: dhowells@redhat.com, Jeff Layton <jlayton@poochiereds.net>,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 04 May 2017 10:27:05 +0100
Message-ID: <16293.1493890025@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Joe Perches <joe@perches.com> wrote:

> krealloc would probably be more efficient and possible
> readable as likely there's already padding in the original
> allocation.

Given there's a maximum of 3 slots, I think it makes better sense to just
allocate them all up front.

David
