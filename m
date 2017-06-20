Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44344 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751122AbdFTTRh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Jun 2017 15:17:37 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, "Alexander Viro" <viro@zeniv.linux.org.uk>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "open list" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 2/2] fs/locks: Remove fl_nspid and use fs-specific l_pid
 for remote locks
Date: Tue, 20 Jun 2017 15:17:34 -0400
Message-ID: <9AA05B58-8D17-4A03-88F8-0F44F346AE0F@redhat.com>
In-Reply-To: <1497978415.4555.14.camel@poochiereds.net>
References: <cover.1497877897.git.bcodding@redhat.com>
 <901367ff4ffd87594a380e3a0a5d20c4e4195b0e.1497877897.git.bcodding@redhat.com>
 <1497893534.4654.11.camel@poochiereds.net>
 <9037C362-D6F7-4545-80C2-08B072005055@redhat.com>
 <D1AFE5C7-427F-4B0B-8337-3D6A247156A3@redhat.com>
 <1497978415.4555.14.camel@poochiereds.net>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 20 Jun 2017, at 13:06, Jeff Layton wrote:
>
> Now that I think about it a bit more, I don't think we really need a
> flag here.
>
> Just have the ->lock operation set the fl_pid to a negative value. That
> will never be a valid pid anyway. Then flock_translate_pid could just
> return any negative value directly instead of trying to translate it.
>
> In practice we would always just set it to -1. Maybe even add something
> like this that the lock-> operation could set it to?
>
> #define    FILE_LOCK_OWNER_UNDEFINED       -1

So for filesystems that set a remote pid, they should negate the pid to mean
that the pid should not be translated?  Then when we return that pid, we
flip it back again, or display a negative number, or turn it into -1?

The flag, having a readable name, would make things a bit clearer as to what
the filesystems expect to happen to that pid value.

Ben
