Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2953 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752032AbaCYSTt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Mar 2014 14:19:49 -0400
Message-ID: <5331964D.10505@RedHat.com>
Date: Tue, 25 Mar 2014 10:44:29 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Benjamin Coddington <bcodding@uvm.edu>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] nfsidmap: a keyringer - 2nd try
References: <cover.1395710586.git.root@hobo-dev.uvm.edu>
In-Reply-To: <cover.1395710586.git.root@hobo-dev.uvm.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/24/2014 09:23 PM, Benjamin Coddington wrote:
> I took a second stab at this since it looks like fixing the keyrings is
> probably the way to go.  This time through, the nfsidmap creates the
> keyrings ad-hoc as they fill up instead of taking new command-line
> parameters.  It also explicitly sets the permissions on the new keyrings, so
> they should be able to be cleaned up in later kernels - though I haven't
> tested that myself.
I'm not going to take these for upstream since I don't think they 
are needed... If that turns out not to be the case, we can add it later...

steved.

> 
> Ben
> 
> Benjamin Coddington (2):
>   nfsidmap: Match names with kernel default keyring
>   nfsidmap: Create id_resolver child keyrings
> 
>  utils/nfsidmap/nfsidmap.c |   76 ++++++++++++++++++++++++++++++++++++---------
>  1 files changed, 61 insertions(+), 15 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
