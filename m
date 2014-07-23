Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:65473 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932584AbaGWSds (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jul 2014 14:33:48 -0400
Date: Wed, 23 Jul 2014 13:33:32 -0500
From: David Teigland <teigland@redhat.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        Christine Caulfield <ccaulfie@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        cluster-devel@redhat.com, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 9/9] fs: dlm: lockd: Convert int result to unsigned char
 type
Message-ID: <20140723183332.GA21992@redhat.com>
References: <cover.1405879494.git.joe@perches.com>
 <65b9ba0dba9c79a938267d5bed7ed0a8211e89ed.1405879494.git.joe@perches.com>
 <20140723141139.2cf90cb0@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140723141139.2cf90cb0@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 23, 2014 at 02:11:39PM -0400, Jeff Layton wrote:
> On Sun, 20 Jul 2014 11:23:43 -0700
> Joe Perches <joe@perches.com> wrote:
> 
> > op->info.rv is an s32, but it's only used as a u8.
> > 
> 
> I don't understand this patch. info.rv is s32 (and I assume that "rv"
> stands for "return value"). What I don't get is why you think it's just
> used as a u8. It seems to be used more like a bool than anything else,

Thank you, Jeff.

        /* info.rv from userspace is 1 for conflict, 0 for no-conflict,
           -ENOENT if there are no locks on the file */

        rv = op->info.rv;

> and I'm not sure that "type" is really a good description for it. Maybe
> it should be a "bool" and named "conflict", given the comments in
> dlm_posix_get ?

type is not a good name.

Sorry Joe, I'm not a fan of your patches.

Dave
