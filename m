Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:61771 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134Ab1HEUdx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Aug 2011 16:33:53 -0400
Subject: Re: [PATCH v2] Update nfs(5) manpage - timeo for NFS/TCP
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110805124015.GA16926@merit.edu>
Date: Fri, 5 Aug 2011 16:33:41 -0400
Cc: Max Matveev <makc@redhat.com>, linux-nfs@vger.kernel.org,
        steved@redhat.com
Message-Id: <703F70DB-E49F-47A0-B101-946147152F8B@oracle.com>
References: <20110805021903.C84608198734@regina.usersys.redhat.com> <20110805124015.GA16926@merit.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 5, 2011, at 8:40 AM, Jim Rees wrote:

> Max Matveev wrote:
> 
>  NFS/TCP does linear backoff then retransmiting - the manpage
>  was mistakenly asserting the "no backoff" theory.
> 
> Actually, now that I made you change the wording, I think the original
> wording was correct.  "Backoff" refers to an increase in the interval
> between retries.  Since the interval is constant, there is no backoff.
> 
> I could be wrong.  I think the term "backoff" was first used this way in
> ALOHA.  I've got some papers around here somewhere and can check.
> 
> But maybe the best thing would be to remove any reference to backoff, and
> talk about retry instead.

I thought that to_maxval was 60 seconds (600 deciseconds).  Once the effective timeo has increased to 60 seconds, it doesn't increase further.  Thus, if the default timeo setting is already 60 seconds, you get effectively a fixed 60 second timeout, right?

If you specify a shorter timeo, then it linearly backs off to the to_maxval setting, which is 600 deciseconds.  But Trond has argued that shorter settings are worse than useless.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



