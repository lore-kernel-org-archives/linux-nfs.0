Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50314 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751076AbdBLBPZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 11 Feb 2017 20:15:25 -0500
Date: Sat, 11 Feb 2017 20:15:21 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: David Windsor <dwindsor@gmail.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-hardening@lists.openwall.com,
        Kees Cook <keescook@chromium.org>,
        "Reshetova, Elena" <elena.reshetova@intel.com>
Subject: Re: [RFC][PATCH] nfsd: add +1 to reference counting scheme for
 struct nfsd4_session
Message-ID: <20170212011521.GD2768@fieldses.org>
References: <1486625901-10094-1-git-send-email-dwindsor@gmail.com>
 <CAEXv5_jUa8Av4JABoKSAueiLHSLzibMvaE-8DrVcxZHFceckMg@mail.gmail.com>
 <1486816302.4233.29.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1486816302.4233.29.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 11, 2017 at 07:31:42AM -0500, Jeff Layton wrote:
> The basic idea here is that nfsv4 sessions have a "resting state" of 0.
> We want to keep them around, but if they go "dead" then we we'll tear
> them down if they aren't actively in use at the time. So, we still free
> the thing when the refcount goes to zero, but we have an extra condition
> before we free it on the put -- that the session is also "dead" (meaning
> that the client asked us to destroy it).
> 
> Your patch doesn't look like it'll break anything, but I personally find
>  it harder to follow that way. The freeable reference state will be 1
> instead of the normal 0.

Alas, I don't have any examples in mind, but doesn't this pattern happen
all over?

You have objects that live in some data structure.  They're freed only
when they're removed from the data structure.  You want removal to fail
whenever they're in use.

So it's natural to use an atomic counter to track the number of external
users and some other lock to serialize lookup and destruction.

--b.
