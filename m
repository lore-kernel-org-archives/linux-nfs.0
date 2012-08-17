Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:20493 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755696Ab2HQPGu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Aug 2012 11:06:50 -0400
Subject: Re: Slowing down state manager after unhandled error
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <502E54D3.4010103@suse.com>
Date: Fri, 17 Aug 2012 11:02:18 -0400
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <DB8AAC61-3940-4CD0-8431-C90A98886901@oracle.com>
References: <502E54D3.4010103@suse.com>
To: Suresh Jayaraman <sjayaraman@suse.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

On Aug 17, 2012, at 10:27 AM, Suresh Jayaraman wrote:

> Hi Trond and Chuck,
> 
> Recently, we have had a report on production SLES system where the
> system's CPU utilization went very high due to the state manager
> constantly sending huge number of requests every second due to an
> unhandled error. The following patch from Chuck
> 
>  https://patchwork.kernel.org/patch/1185421/
> 
> mitigated this issue. Would be interested to know whether this patch
> queued up already or you see any problem with the approach.

It got dropped for 3.6 simply because it was at the end of a patch series that was truncated in the middle.  I'm submitting it again for 3.7.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




