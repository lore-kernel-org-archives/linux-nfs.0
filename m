From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs-utils: make nfsstat read and print stats as
 unsigned integers
Date: Wed, 16 Apr 2008 12:41:17 -0400
Message-ID: <20080416124117.5ebdd0e4@barsoom.rdu.redhat.com>
References: <1208362206-19653-1-git-send-email-jlayton@redhat.com>
	<Pine.BSO.4.64.0804161226420.16179@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: steved@redhat.com, linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "david m. richter" <richterd@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755512AbYDPQlV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2008 12:41:21 -0400
In-Reply-To: <Pine.BSO.4.64.0804161226420.16179@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Apr 2008 12:29:26 -0400 (EDT)
"david m. richter" <richterd@citi.umich.edu> wrote:

> 	hello, jeff,
> 
> 	i think one other place that could use a signed->unsigned fix is 
> in parse_pretty_statfile(), where "sum" is declared as signed but actually 
> represents an unsigned total.
> 
> 	thanks,
> 
> 	d
> 	.
> 	


Thanks, Dave. Good catch. I'll respin and repost...
-- 
Jeff Layton <jlayton@redhat.com>
