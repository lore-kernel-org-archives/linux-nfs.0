Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47714 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751978AbaKDTtO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Nov 2014 14:49:14 -0500
Message-ID: <54592DB7.8010107@RedHat.com>
Date: Tue, 04 Nov 2014 14:49:11 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Benjamin Coddington <bcodding@redhat.com>, linux-nfs@vger.kernel.org
CC: chuck.lever@oracle.com
Subject: Re: [PATCH 0/2] nfsidmap not setting key timeouts
References: <cover.1415036893.git.bcodding@redhat.com>
In-Reply-To: <cover.1415036893.git.bcodding@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/03/2014 12:49 PM, Benjamin Coddington wrote:
> These should fix up nfsidmap being unable to set key timeouts.
> 
> Benjamin Coddington (2):
>   nfsidmap: set the correct DEFAULT_KEYRING string
>   nfsidmap: Correct a failure to set key timeout values
Both committed... 

steved.

> 
>  utils/nfsidmap/nfsidmap.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
