Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43723 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751019AbaGGTbK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jul 2014 15:31:10 -0400
Date: Mon, 7 Jul 2014 15:31:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH] nfsd: close potential race between delegation break and
 laundromat
Message-ID: <20140707193108.GF8630@fieldses.org>
References: <1404759818-10350-1-git-send-email-jlayton@primarydata.com>
 <20140707151450.7abd3db8@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140707151450.7abd3db8@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 07, 2014 at 03:14:50PM -0400, Jeff Layton wrote:
> Sigh...after staring at this patch all day, I think I now see a
> potential problem with the fault injection piece.
> 
> In the "recall" case, we may find a delegation on the cl_delegations
> list that has already been recalled. If that's the case, then we
> probably should just skip it.
> 
> I'll fix this patch, retest and resend. Sorry for the noise...

OK, so sounds like the fix isn't a big deal, but it also sounds like the
fault injection code has come up as needing special attention a few
times during this work now.

Has anyone actually ended up using that code?  Anna?

In retrospect I wonder if it's worth the trouble.  It's very
special-purpose stuff and if nobody's using it then maybe we could just
remove it....

--b.
