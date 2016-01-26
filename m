Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20785 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752881AbcAZTWS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2016 14:22:18 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [PATCH 0/5] Convert client back-channel to use session slot table
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1453730956-5325-1-git-send-email-trond.myklebust@primarydata.com>
Date: Tue, 26 Jan 2016 14:22:11 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <DC9FDB91-FE65-46B1-9287-E12BC6938048@oracle.com>
References: <1453730956-5325-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 25, 2016, at 9:09 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> The following patchset is intended to convert the current ad-hoc backchannel
> session semantics to use the generic slot table in fs/nfs/nfs4session.c
> This should suffice to allow us to grow the size of the slot table at will.

We may be able to exercise this series at Connectathon with
some RDMA servers that advertise quite a few backchannel
session slots.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> Trond Myklebust (5):
>  NFSv4.x: Remove hard coded slotids in callback channel
>  NFSv4.x: CB_SEQUENCE should return NFS4ERR_DELAY if still executing
>  NFSv4.x: Enforce the ca_maxresponsesize_cached on the back channel
>  NFSv4.x: Fix wraparound issues when validing the callback sequence id
>  NFSv4.x: Allow multiple callbacks in flight
> 
> fs/nfs/callback.h      |  3 ++-
> fs/nfs/callback_proc.c | 64 ++++++++++++++++++++++++++------------------------
> fs/nfs/callback_xdr.c  | 12 ++++++----
> fs/nfs/nfs4proc.c      |  2 +-
> fs/nfs/nfs4session.c   | 54 ++++++++++++++++++++++++++++++++----------
> fs/nfs/nfs4session.h   |  8 +++++++
> 6 files changed, 93 insertions(+), 50 deletions(-)
> 
> -- 
> 2.5.0

--
Chuck Lever




