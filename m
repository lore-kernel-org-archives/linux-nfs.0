Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56410 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763387Ab3ECTjo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 May 2013 15:39:44 -0400
Date: Fri, 3 May 2013 15:39:41 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: long delay when mounting due to SETCLIENTID AUTH_GSS attempts
Message-ID: <20130503153941.345d3b9a@tlielax.poochiereds.net>
In-Reply-To: <EB1CC0C3-1E31-4A3F-90E7-A79098161D1B@oracle.com>
References: <20130503132557.2fdf794d@tlielax.poochiereds.net>
	<AE700845-4032-4BEC-817C-97EB08A831E8@oracle.com>
	<20130503142421.19fb3ca6@tlielax.poochiereds.net>
	<1367606034.3556.25.camel@leira.trondhjem.org>
	<20130503144437.3a47e476@tlielax.poochiereds.net>
	<A2E5B3F1-A8F1-4731-A66C-548B9C8FD429@oracle.com>
	<20130503151727.09d684f4@tlielax.poochiereds.net>
	<EB1CC0C3-1E31-4A3F-90E7-A79098161D1B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 3 May 2013 15:26:09 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> I don't expect this issue to last for release after release.  A moment ago you agreed that this shouldn't be intractable, so I fail to see the need to start wiring up long-term workarounds.
> 
> Can't we just agree on a fix, and then get that into 3.10 as a regression fix?
> 

I'm happy to help...I'm just not sure what you're proposing as the fix
for the problem. What are you suggesting we do?

-- 
Jeff Layton <jlayton@redhat.com>
