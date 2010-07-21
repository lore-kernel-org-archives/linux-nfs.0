Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46641 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755137Ab0GUXZR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 19:25:17 -0400
Date: Wed, 21 Jul 2010 19:24:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/5] nfsd: just keep single lockd reference for nfsd
 (try #4)
Message-ID: <20100721232432.GA6689@fieldses.org>
References: <1279718501-6834-1-git-send-email-jlayton@redhat.com>
 <20100721201437.GD28123@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100721201437.GD28123@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 21, 2010 at 04:14:37PM -0400, J. Bruce Fields wrote:
> (Incremental on top of your last patch, with some noise due to moving
> stuff around to avoid forward references.  I'll clean these up and
> resend.)
> 
> Then we could also get rid of some of the individual flags (nfs4_init at
> least), I think.

Here's what I'm thinking of applying.  (Lightly tested.)

--b.
