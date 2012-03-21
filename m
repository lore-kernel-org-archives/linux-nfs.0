Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51033 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752881Ab2CUX70 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 19:59:26 -0400
Date: Wed, 21 Mar 2012 19:59:46 -0400
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v10 2/8] nfsd: add nfsd4_client_tracking_ops struct and
 a way to set it
Message-ID: <20120321195946.67c88cf9@redhat.com>
In-Reply-To: <1332337929-18580-3-git-send-email-jlayton@redhat.com>
References: <1332337929-18580-1-git-send-email-jlayton@redhat.com>
	<1332337929-18580-3-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 21 Mar 2012 09:52:03 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> Abstract out the mechanism that we use to track clients into a set of
> client name tracking functions.
> 
> This gives us a mechanism to plug in a new set of client tracking
> functions without disturbing the callers. It also gives us a way to
> decide on what tracking scheme to use at runtime.
> 
> For now, this just looks like pointless abstraction, but later we'll
> add a new alternate scheme for tracking clients on stable storage.
> 
> Note too that this patch anticipates the eventual containerization
> of this code by passing in struct net pointers in places. No attempt
> is made to containerize the legacy client tracker however.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/nfs4recover.c |  136 +++++++++++++++++++++++++++++++++++++++++++++----
>  fs/nfsd/nfs4state.c   |   61 +++++++---------------
>  fs/nfsd/state.h       |   15 +++--
>  3 files changed, 155 insertions(+), 57 deletions(-)
> 

Bruce pointed out that I missed converting a spot in the new fault
injection code, so I've followed this up with a v11 patch that fixes
that problem.

Cheers!
-- 
Jeff Layton <jlayton@redhat.com>
