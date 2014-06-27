Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:65113 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751277AbaF0TIG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Jun 2014 15:08:06 -0400
Received: by mail-qc0-f174.google.com with SMTP id x13so4811054qcv.5
        for <linux-nfs@vger.kernel.org>; Fri, 27 Jun 2014 12:08:05 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 27 Jun 2014 15:08:03 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 000/117] nfsd: eliminate the client_mutex
Message-ID: <20140627150803.3d663208@tlielax.poochiereds.net>
In-Reply-To: <20140627162234.GA15610@fieldses.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
	<20140627162234.GA15610@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 27 Jun 2014 12:22:34 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Jun 26, 2014 at 03:11:40PM -0400, Jeff Layton wrote:
> > I'd still like to see this merged for v3.17, so it would be ideal to
> > merge this into linux-next soon if possible. Bruce, please let me know
> > what you think the prospects are.
> 
> I'm currently using the "for-3.17" branch at
> 
> 	git://linux-nfs.org/~bfields/linux.git
> 
> to hold any changes that I think are well and truly committed (so that
> should be rebased never or only very rarely) and "nfsd-next" for things
> that have been posted but may still be waiting for review (including
> these), and may still be revised or dropped.
> 
> I should probably come up with some more sensible scheme....
> 

Ahh ok, I had looked the other day and didn't see them merged so I
figured it wouldn't hurt to resend them. Thanks for putting the pile
into nfsd-next! Let's hope it shakes loose some more bugs ;)

> I already had the first six patches.  I assumed without checking really
> carefully that you hadn't revised the versions you sent me, let me know
> if otherwise.
> 

That's correct -- the first six patches are unchanged.

-- 
Jeff Layton <jlayton@primarydata.com>
