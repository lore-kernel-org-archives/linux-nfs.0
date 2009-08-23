From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Handle a zero-length auth flavor list
Date: Sun, 23 Aug 2009 14:57:01 -0400
Message-ID: <50C4E02A-ADB5-454B-8B13-751C8E737A9F@oracle.com>
References: <20090821215006.28834.73753.stgit@matisse.1015granger.net> <1250962458.8143.24.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:38365 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933820AbZHWTc4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Aug 2009 15:32:56 -0400
In-Reply-To: <1250962458.8143.24.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 22, 2009, at 1:34 PM, Trond Myklebust wrote:
> On Fri, 2009-08-21 at 17:50 -0400, Chuck Lever wrote:
>> Some releases of Linux rpc.mountd (nfs-utils 1.1.4 and later)  
>> return an
>> empty auth flavor list if no sec= was specified for the export.   
>> This is
>> notably broken server behavior.
>>
>> The new auth flavor list checking added in a recent commit rejects  
>> this
>> case.  The OpenSolaris client does too.
>>
>> The broken mountd implementation is already widely deployed.  To  
>> avoid
>> a behavioral regression, the kernel's mount client skips flavor  
>> checking
>> (ie reverts to the pre-2.6.32 behavior) if mountd returns an empty
>> flavor list.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> Trond-
>>
>> First proposal to address the empty flavor list regression.
>
> Looks alright. Do we know that it fixes the problem for Fengguang?

Nope, posted only here on linux-nfs for discussion and review first.   
Thanks for forwarding.

If this was an issue in 2.6.31-rc, the patch description should  
probably read "pre-2.6.31" not "pre-2.6.32".

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
