Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18269 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758030Ab3DXV2t convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2013 17:28:49 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Dave Chiluk <chiluk@canonical.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Use exponential backoff delay for NFS4_ERRDELAY
Date: Wed, 24 Apr 2013 21:28:47 +0000
Message-ID: <1366838926.22397.25.camel@leira.trondhjem.org>
References: <1366836949-18465-1-git-send-email-chiluk@canonical.com>
In-Reply-To: <1366836949-18465-1-git-send-email-chiluk@canonical.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-04-24 at 15:55 -0500, Dave Chiluk wrote:
> Changing the retry to start at NFS4_POLL_RETRY_MIN and exponentially grow
> to NFS4_POLL_RETRY_MAX allow for faster handling of these error conditions.
> 
> Additionally this alleviates an interoperability problem with the AIX NFSv4
> Server.  The AIX server frequently (2 out of 3) returns NFS4ERR_DELAY, on a
> close when it happens in close proximity to a RELEASE_LOCKOWNER.  This would
> cause a linux client to hang for 15 seconds.

Hi Dave,

The AIX server is not being motivated by any requirements in the NFSv4
spec here, so I fail to see the reason why the behaviour that you
describe can justify changing the client. It is not at all obvious to me
that we should be retrying aggressively when NFSv4 servers return
NFS4ERR_DELAY. What makes 1/10sec more correct in these situations than
the exising 15 seconds?

The motivation for doing it in the case of OPEN, SETATTR, etc is
clearer: those operations may require the server to recall a delegation,
in which case aggressive retries are in order since delegation recalls
are usually fast.
The motivation in the case of LOCK is less clear, but it is basically
down to the fact that NFSv4 has a polling model for doing blocking
locks.
In all other cases, why should we be treating NFS4ERR_DELAY any
differently from how we treat NFS3ERR_JUKEBOX in NFSv3?

Note that if we do decide that changing the client is the right thing,
then I don't want the patch to add new fields to struct rpc_task. That's
the wrong layer for storing NFSv4 client specific data.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
