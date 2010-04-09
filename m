Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:33014 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756565Ab0DIU0I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Apr 2010 16:26:08 -0400
Message-ID: <4BBF8D25.7050506@oracle.com>
Date: Fri, 09 Apr 2010 16:25:09 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: David Teigland <teigland@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: lockd and lock cancellation
References: <20100409194018.GA11823@redhat.com>
In-Reply-To: <20100409194018.GA11823@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi David-

On 04/09/2010 03:40 PM, David Teigland wrote:
> Here's what I think was the first time we discussed cancelation and
> Bruce's provisional locks: http://marc.info/?t=116538335700005&r=1&w=2
> I'm still skeptical of trying to handle cancels, it seems too complex to
> become reliable in the lifetime of nfs3.
>
> What I would be interested to see fixed is this oops that's not difficult
> to trigger by doing lock/unlock loops on a client:
> https://bugzilla.redhat.com/show_bug.cgi?id=502977#c18
>
> But, for all the kernel work on these nfs/gfs/dlm hooks, there's a larger
> issue that no one is working on AFAIK:  the mechanisms for recovering
> client locks on remaining gfs nodes when one gfs node fails.  That would
> take a lot of work, and until it's done all the kernel apis will be a moot
> point since clustered nfs locks on gfs will be unusable.

To support IPv6, I've studied and modified the NFSv2/v3 lock recovery 
mechanisms quite a bit recently.  What kernel APIs do you think would be 
needed to manage cluster lock recovery?  Just something to release stale 
locks on a single node?

-- 
chuck[dot]lever[at]oracle[dot]com
