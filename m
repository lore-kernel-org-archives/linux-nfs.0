Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:20354 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757930Ab2EQUUu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 16:20:50 -0400
Subject: Re: [PATCH v2] statd: drop all capabilities from the bounding set as well
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120517161114.5cebfa68@tlielax.poochiereds.net>
Date: Thu, 17 May 2012 16:20:40 -0400
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Message-Id: <07DEAF11-29E7-4292-A425-2587BF682269@oracle.com>
References: <1337277259-5101-1-git-send-email-jlayton@redhat.com> <73BC4C93-9192-4FE7-B32E-58345EB28AAD@oracle.com> <20120517161114.5cebfa68@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 17, 2012, at 4:11 PM, Jeff Layton wrote:

> On Thu, 17 May 2012 14:52:58 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On May 17, 2012, at 1:54 PM, Jeff Layton wrote:
>> 
>>> statd drops all capabilities except for CAP_NET_BIND when it starts. It's
>>> possible though that if it ever had a compromise that an attacker would be
>>> able to invoke a setuid process (or something with file capabilities) in
>>> order to reinstate some caps.
>>> 
>>> This could happen as a result of the daemon becoming compromised, or
>>> possibly as a result of the ha-callout program becoming compromised.
>> 
>> Generally, I wonder what our exposure to this attack for a statd built without capability support.  Just musing out loud.
>> 
> 
> It is difficult to qualify this without a specific attack in mind. The
> story I've always gotten from those who work with capabilities for a
> living however is that unless you prune the bounding set, the job isn't
> complete.

My question was muddled.  I'll try again.  If statd is built with "--disable-caps", then I think statd won't drop capabilities at all.  Are we agreeing that nothing can be done in that case to mitigate this kind of attack?

> Given the right circumstances, a process could reacquire capabilities
> via exec'ing a (possibly compromised) setuid program or one with file
> caps.
> 
> Since we've taken a step to trim out capabilities that we do not deem
> necessary for normal statd functioning, you can consider this to be
> trimming that list even further. This patch effectively says that statd
> should never be able to reacquire caps that it has dropped under any
> circumstances.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




