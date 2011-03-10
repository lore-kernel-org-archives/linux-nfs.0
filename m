Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:57685 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab1CJRMp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 12:12:45 -0500
Subject: Re: [PATCH] NFS: Fix handling of commmand line options for NFSROOT
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110310160720.GC27206@opensource.wolfsonmicro.com>
Date: Thu, 10 Mar 2011 12:11:42 -0500
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        patches@opensource.wolfsonmicro.com
Message-Id: <01334E4A-E72F-4734-A9A6-B881D66E0C50@oracle.com>
References: <1299771798-29285-1-git-send-email-broonie@opensource.wolfsonmicro.com> <382578FF-22A9-4840-B3A7-EFEFA5453C35@oracle.com> <20110310160720.GC27206@opensource.wolfsonmicro.com>
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Mar 10, 2011, at 11:07 AM, Mark Brown wrote:

> On Thu, Mar 10, 2011 at 10:59:24AM -0500, Chuck Lever wrote:
>> On Mar 10, 2011, at 10:43 AM, Mark Brown wrote:
> 
>>> Commmit 972903 (NFS: NFSROOT should default to "proto=udp") added a
>>> default NFS mount option using the existing in-kernel code to parse
>>> mount options out of the command line. This exposed a bug in the
> 
>> Looks like a real bug.
> 
> Well, it's stopped me booting any of my systems with -next for a couple
> of days :)

Thanks for your testing.

>> We might be better off teaching root_nfs_cat() to deal with the extra
>> comma as necessary right when we concatenate the options strings.
>> That would simplify it's callers.
> 
> The thought did cross my mind, yes.

That sounds like you'd like me to volunteer to do that.  :-)

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




