From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 0/2] Bugfixes for zero stateID RPCs
Date: Sun,  6 Dec 2009 03:16:22 -0800
Message-ID: <1260098184-19209-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31213 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933671AbZLFLWI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 6 Dec 2009 06:22:08 -0500
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following two patches fix the problem where we send RPCs with
sessionID of 0 during session recovery.  Failed CREATE_SESSION
recovery is now done within the state manager for NFS4ERR_STALE_CLIENTID.
I believe the same applies to NFS4ERR_DELAY, but I had no way of
testing it so I did not add the error case at this time.

[PATCH 1/2] nfs41: nfs41_setup_state_renewal
[PATCH 2/2] nfs41: Don't clear DRAINING flag on NFS4ERR_STALE_CLIENTID

- ricardo


