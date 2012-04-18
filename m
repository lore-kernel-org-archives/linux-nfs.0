Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64440 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754161Ab2DRRhC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 13:37:02 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Luis Henriques <luis.henriques@canonical.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] Fix regression on NFS in mainline kernel
Date: Wed, 18 Apr 2012 13:36:52 -0400
Message-Id: <1334770614-10653-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <20120418105147.2a6f1c55@corrin.poochiereds.net>
References: <20120418105147.2a6f1c55@corrin.poochiereds.net>
In-Reply-To: <20120418105147.2a6f1c55@corrin.poochiereds.net>
References: <20120418105147.2a6f1c55@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The first patch addresses the Oops.
The second will hopefully address the looping.

Trond Myklebust (2):
  NFSv4: Ensure that the LOCK code sets exception->inode
  NFSv4: Ensure that we check lock exclusive/shared type against open
    modes

 fs/nfs/nfs4proc.c |   23 +++++++++++++++++++++--
 1 files changed, 21 insertions(+), 2 deletions(-)

-- 
1.7.7.6

