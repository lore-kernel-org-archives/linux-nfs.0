Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:36985 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920Ab2CLThJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 15:37:09 -0400
Message-ID: <4F5E5054.3000304@panasas.com>
Date: Mon, 12 Mar 2012 12:36:52 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <lsf-pc@lists.linux-foundation.org>, <linux-nfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>
Subject: Re: [bfields: [LSF/MM TOPIC] fileservers' filesystem wishlist]
References: <20120312151707.GD4752@fieldses.org>
In-Reply-To: <20120312151707.GD4752@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/12/2012 08:17 AM, J. Bruce Fields wrote:
> Apologies, this is late for a topic proposal--and I'm not really certain
> whether it merits a separate "topic" or whether it's really just an
> add-on to Ric's "linux servers as a storage server - what's missing?".
> 
> In any case, I'd love to have a slot to run through a file servers'
> filesystem wishlist; probably a slide or two each for features such as:
> 
> 	- change attributes
> 	- delegations/opLocks
> 	- share locks
> 	- deleted-file recovery/server-side sillyrename
> 	- lock recovery
> 
> with a brief summary of each (and of current status in cases where we
> have a partial solution already).
> 
> Plus a little time to discuss each feature, depending on interest.
> 
> My main interest is knfsd, but I'd also like to look at what we could do
> for userspace (SMB and NFS) servers.
> 
> I recall doing something like this (five years ago?) at the first LSF,
> and it was quite helpful (though some of the same problems remain).
> 

All these topics are very important for me too

Thanks
Boaz

> --b.
> 
> (Resent to correct cc: list, sorry!)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

