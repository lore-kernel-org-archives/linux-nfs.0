Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32526 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935756Ab1ETUOE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 May 2011 16:14:04 -0400
Message-ID: <4DD6CB82.2000603@netapp.com>
Date: Fri, 20 May 2011 16:13:54 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: bjschuma@netapp.com
CC: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/2] NFSD: add FREE_STATEID and TEST_STATEID operations
References: <1305922380-8162-1-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1305922380-8162-1-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The subject should read "v3" here.  Sorry about that.

- Bryan

On 05/20/2011 04:12 PM, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> These patches add FREE_STATEID and TEST_STATEID to the NFS server.  I
> appreciate any comments, especially if there is a better way of doing things.
> 
> v2:
> - FREE_STATEID
>   - Free open, lock, and delegation state ids correctly
>   - Use the check_for_locks() function to check for locks
> 
> - TEST_STATEID
>   - Remove openmode check
>   - Sanity check on size of stateid list
>   - Delay decoding stateid list until encoding the reply
> 
> v3:
> - FREE_STATEID
>   - Open stateids and delegations are never freeable (return nfserr_locks_held)
> 
> - TEST_STATEID
>   - Remove unused arguments from a function call
>   - Store and use the HAS_SESSION flag for validating stateids
> 
> Thanks!
> 
> - Bryan

