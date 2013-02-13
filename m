Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52621 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760246Ab3BMUO4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Feb 2013 15:14:56 -0500
Message-ID: <511BF40E.1020704@RedHat.com>
Date: Wed, 13 Feb 2013 15:14:06 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "J.Bruce Fields" <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - libtirpc] Add authgss_free_private_data interface.
References: <20130205112309.1b0945ab@notabene.brown>
In-Reply-To: <20130205112309.1b0945ab@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/02/13 19:23, NeilBrown wrote:
> This is a necessary partner to authgss_get_private_data, so that
> the caller can free the data when needed (and not before).
> 
> The previous practice of leaving the private data where it was resulted
> in authgss_destroy_context() attempting to destroy the context on the
> server which was incorrect, and fortunately fails for other reasons.
> 
> An application which uses authgss_get_private_data() but does not call
> authgss_free_private_data() will be as correct as, or slightly more
> correct than, it was, but will suffer a slight memory leak.
> 
> This patch is based on commit 07fce317cac267509b944a8191cafa8e49b5e328
> from librpcsecgss that was committed by Kevin Coffman.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed... 

steved.
