Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34968 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754290Ab2K0W3c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 17:29:32 -0500
Date: Tue, 27 Nov 2012 17:29:29 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH 0/5] nfsd: more NFSv4 state containerization
Message-ID: <20121127222929.GK27142@fieldses.org>
References: <20121126121907.955.25349.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121126121907.955.25349.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 26, 2012 at 03:21:49PM +0300, Stanislav Kinsbursky wrote:
> This patch set makes NFSv4 state created and destroyed per net and thus
> completes it's containerization (the only exceprtion is client_mutex, but this
> one a hard nut to crack).
> 
> Note: patch set depend on previously sent patch named "nfsd4: remove state
> lock from nfs4_state_shutdown".

Looks OK.--b.

> 
> The following series implements...
> 
> ---
> 
> Stanislav Kinsbursky (5):
>       nfsd: make client_lock per net
>       nfsd: make delegations shutdown network namespace aware
>       nfsd: cleanup NFSd state shutdown a bit
>       nfsd: cleanup NFSd state start a bit
>       nfsd: call state init and shutdown twice
> 
> 
>  fs/nfsd/netns.h     |    3 +
>  fs/nfsd/nfs4state.c |  137 +++++++++++++++++++++++++++++----------------------
>  fs/nfsd/nfsd.h      |    4 +
>  fs/nfsd/nfssvc.c    |   15 +++++-
>  4 files changed, 99 insertions(+), 60 deletions(-)
> 
