Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52987 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933227Ab1LFL4H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Dec 2011 06:56:07 -0500
Date: Tue, 6 Dec 2011 06:56:06 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@tonian.com>
Cc: Benny Halevy <benny@tonian.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/13] pnfsd-block: reverse boolean_t values so they
 make sense
Message-ID: <20111206115606.GA8474@fieldses.org>
References: <4EDB79A9.2080109@tonian.com>
 <1323006496-13542-1-git-send-email-benny@tonian.com>
 <20111206021059.GB4486@fieldses.org>
 <4EDDFC39.4090800@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EDDFC39.4090800@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 06, 2011 at 01:27:53PM +0200, Benny Halevy wrote:
> On 2011-12-06 04:10, J. Bruce Fields wrote:
> > On Sun, Dec 04, 2011 at 03:48:16PM +0200, Benny Halevy wrote:
> >> From: Benny Halevy <bhalevy@tonian.com>
> >>
> >> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> >> ---
> >>  fs/nfsd/bl_ops.c |    2 +-
> >>  1 files changed, 1 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/fs/nfsd/bl_ops.c b/fs/nfsd/bl_ops.c
> >> index 89249c4..4d2939e 100644
> >> --- a/fs/nfsd/bl_ops.c
> >> +++ b/fs/nfsd/bl_ops.c
> >> @@ -57,7 +57,7 @@
> >>  #endif
> >>  
> >>  
> >> -typedef enum {True, False} boolean_t;
> >> +typedef enum {False = 0, True = !False} boolean_t;
> > 
> > Shouldn't we just use "bool"?
> 
> Yes, in some cases. In others, the boolean status doesn't make sense
> and I'd like to replace it with an integer.

I believe casts from bools to integers are defined to convert false and
true to 0 and 1 respectively, so you should be fine.

--b.
