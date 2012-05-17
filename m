Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52570 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756599Ab2EQUzp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 May 2012 16:55:45 -0400
Date: Thu, 17 May 2012 16:55:42 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] statd: drop all capabilities from the bounding set
 as well
Message-ID: <20120517165542.3b10740d@tlielax.poochiereds.net>
In-Reply-To: <07DEAF11-29E7-4292-A425-2587BF682269@oracle.com>
References: <1337277259-5101-1-git-send-email-jlayton@redhat.com>
	<73BC4C93-9192-4FE7-B32E-58345EB28AAD@oracle.com>
	<20120517161114.5cebfa68@tlielax.poochiereds.net>
	<07DEAF11-29E7-4292-A425-2587BF682269@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 17 May 2012 16:20:40 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On May 17, 2012, at 4:11 PM, Jeff Layton wrote:
> 
> > On Thu, 17 May 2012 14:52:58 -0400
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> >> 
> >> On May 17, 2012, at 1:54 PM, Jeff Layton wrote:
> >> 
> >>> statd drops all capabilities except for CAP_NET_BIND when it starts. It's
> >>> possible though that if it ever had a compromise that an attacker would be
> >>> able to invoke a setuid process (or something with file capabilities) in
> >>> order to reinstate some caps.
> >>> 
> >>> This could happen as a result of the daemon becoming compromised, or
> >>> possibly as a result of the ha-callout program becoming compromised.
> >> 
> >> Generally, I wonder what our exposure to this attack for a statd built without capability support.  Just musing out loud.
> >> 
> > 
> > It is difficult to qualify this without a specific attack in mind. The
> > story I've always gotten from those who work with capabilities for a
> > living however is that unless you prune the bounding set, the job isn't
> > complete.
> 
> My question was muddled.  I'll try again.  If statd is built with "--disable-caps", then I think statd won't drop capabilities at all.  Are we agreeing that nothing can be done in that case to mitigate this kind of attack?
> 

Probably not...

If a build specifies --disable-caps, then I take that to mean that it
shouldn't try to do anything with capabilities. I see that increased
exposure as the price you pay for not building against libcap.

Given that, I'll ensure that we don't attempt to modify the bounding
set too in that case...

-- 
Jeff Layton <jlayton@redhat.com>
