Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:40090 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757085Ab2ADWH0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2012 17:07:26 -0500
Subject: Re: [PATCH] NFS: Fix a few issues with cached state owners
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1325714612.25276.1.camel@lade.trondhjem.org>
Date: Wed, 4 Jan 2012 17:07:21 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <C0783437-7D8F-4A45-913A-B49692D37AC2@oracle.com>
References: <1325697256.18462.24.camel@lade.trondhjem.org> <1325713927-25519-1-git-send-email-Trond.Myklebust@netapp.com> <BB6B1D30-BEA3-402E-BF77-1C21F182C46F@oracle.com> <A9614C89-6666-420F-B945-B5C879034086@oracle.com> <1325714612.25276.1.camel@lade.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 4, 2012, at 5:03 PM, Trond Myklebust wrote:

> On Wed, 2012-01-04 at 16:58 -0500, Chuck Lever wrote: 
>> On Jan 4, 2012, at 4:56 PM, Chuck Lever wrote:
>> 
>>> 
>>> On Jan 4, 2012, at 4:52 PM, Trond Myklebust wrote:
>>> 
>>>> The garbage collector needs to remove the entry from the lru list
>>>> _and_ the red-black tree atomically in order avoid races in
>>>> nfs4_get_state_owner.
>>>> 
>>>> Fix a case in nfs4_get_state_owner in which the garbage-collector
>>>> list was being manipulated while not holding the appropriate spin
>>>> lock.
>>>> 
>>>> nfs4_drop_state_owner doesn't need to look at sp->so_lru: the caller
>>>> must have a reference to the state owner, so it can't be on the
>>>> garbage-collection list.
>>>> 
>>>> Run the garbage collector _after_ we've looked up the state owner
>>>> for efficiency reasons.
>>>> 
>>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> 
>>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>> 
>> You might consider squashing this with my patch.  The list_del_init() outside the cl_lock is enough to warrant it.
> 
> Sure, as long as you're fine with that.

Usually I like to see who did what, but I think this should be one patch for better bisecting behavior and to make it easy for distributors to find and apply this fix.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




