Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754085AbaISPU6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 11:20:58 -0400
Message-ID: <541C49D3.6020903@RedHat.com>
Date: Fri, 19 Sep 2014 11:20:51 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@primarydata.com>
CC: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 0/7] nfs-utils: support for lifting grace period early
References: <1411134770-2409-1-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1411134770-2409-1-git-send-email-jlayton@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/19/2014 09:52 AM, Jeff Layton wrote:
> v5:
> - fix build break in middle of set
> 
> v4:
> - replace "reclaim_complete" timestamp column with "has_session" boolean
> - change to use NFSDCLTRACK_CLIENT_HAS_SESSION environment variable
> - only set timestamp on "has_session" clients during "create" op
> 
> v3:
> - account for change to NFSDCLTRACK_RECLAIM_COMPLETE env var
> 
> This is v5 of the patchset to allow the lifting of the grace period
> early. The only difference from the v4 set is a fix for a build break
> that was introduced in the middle of the set (mea culpa!). The end
> result here should be exactly the same as in the v4 set.
> 
> At this point, Bruce has indicated that he intends to merge these patches
> for v3.18, so I think this set is also ready for merge into nfs-utils.
> 
> Jeff Layton (7):
>   sm-notify: inform the kernel if there were no hosts to notify
>   nfsdcltrack: update comments in sqlite.c
>   nfsdcltrack: rename CLD_* constants with CLTRACK_* prefixes
>   nfsdcltrack: overhaul database initializtion
>   nfsdcltrack: update schema to v2
>   nfsdcltrack: grab the NFSDCLTRACK_CLIENT_HAS_SESSION env var if it's
>     present
>   nfsdcltrack: fetch NFSDCLTRACK_GRACE_START out of environment
> 
>  utils/nfsdcltrack/nfsdcltrack.c | 103 ++++++++++-
>  utils/nfsdcltrack/sqlite.c      | 388 ++++++++++++++++++++++++++++++----------
>  utils/nfsdcltrack/sqlite.h      |   8 +-
>  utils/statd/sm-notify.c         |  25 +++
>  4 files changed, 421 insertions(+), 103 deletions(-)
> 
Committed... 

steved.

