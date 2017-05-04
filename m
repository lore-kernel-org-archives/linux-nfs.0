Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48576 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753182AbdEDMzN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 May 2017 08:55:13 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <87fugl3c22.fsf@rasmusvillemoes.dk>
References: <87fugl3c22.fsf@rasmusvillemoes.dk> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Subject: Re: [PATCH 4/9] Implement fsopen() to prepare for a mount
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 04 May 2017 13:55:10 +0100
Message-ID: <22923.1493902510@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rasmus Villemoes <linux@rasmusvillemoes.dk> wrote:

> OK, mc->error must be static data, so no lifetime problems.

Technically, mc->error is only good as long as we hold a ref on its module.
It might be better to copy the string, especially as we can then do
printf-style formatting.

> But is it possible for the compiler to mess this up and reload msg from
> mc->error when it's about to do the user copy, so that if some other thread
> has managed to change mc->error (or is the error state sticky and no further
> operations allowed?) we'd copy from a string with a different length?

Yeah - I need to put a READ_ONCE() in there.

> Where does fs_name now get freed? vfs_fsopen doesn't seem to do it on
> success? (If it did, the fallthrough from err_mc: to err_fs_name: would
> be wrong.)

I'll add a free right after the vfs_fsopen() call before checking the error -
then I can get rid of err_fs_name.

David
