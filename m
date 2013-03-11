Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43984 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754245Ab3CKTgk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 15:36:40 -0400
Date: Mon, 11 Mar 2013 15:36:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Pavel Shilovsky <piastry@etersoft.ru>, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: Re: [PATCH v3 7/7] NFSD: Pass share reservations flags to VFS
Message-ID: <20130311193638.GB642@fieldses.org>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
 <1362065133-9490-8-git-send-email-piastry@etersoft.ru>
 <20130311150540.119abd63@corrin.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130311150540.119abd63@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 11, 2013 at 03:05:40PM -0400, Jeff Layton wrote:
> knfsd has some code already to handle share reservations internally.
> Nothing outside of knfsd is aware of these reservations, of course so
> moving to a vfs-level object for it would be a marked improvement.
> 
> It doesn't look like this patch removes any of that old code though. I
> think it probably should, or there ought to be some consideration of
> how this new stuff will mesh with it.
> 
> I think you have 2 choices here:
> 
> 1/ rip out the old share reservation code altogether and require that
> filesystems mount with -o sharemand or whatever if they want to allow
> their enforcement
> 
> 2/ make knfsd fall back to using the internal share reservation code
> when the mount option isn't enabled
> 
> Personally, I think #1 would be fine, but Bruce may want to weigh in on
> what he'd prefer.

#1 sounds good.  Clients that use deny bits are few.  My preference
would be to return an error to such clients in the case share locks
aren't available.

(We're a little out of spec there, so I'm not sure which error.  I think
the goal is to notify a human there's a problem with minimal collateral
damange.

NFS4ERR_SERVERFAULT ("I'm a buggy server, sorry about that!") would
probably result in an IO error to the application.

SHARE_DENIED strikes me as unsafe: an application would be in its rights
not to even check for that e.g. in the case of an exclusive create.

Maybe DELAY?  Kind of ridiculous, but blocking the application
indefinitely would probably get someone's attention quickly enough
without doing any damnage.)

--b.
