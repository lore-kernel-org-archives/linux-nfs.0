Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:34799 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877Ab0GHPDC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jul 2010 11:03:02 -0400
Message-ID: <4C35E874.3050809@oracle.com>
Date: Thu, 08 Jul 2010 11:02:12 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Fill in WCC data for REMOVE, RMDIR, MKNOD, and
 MKDIR
References: <20100706204750.2918.92546.stgit@ellison.1015granger.net> <20100707211037.GF2957@fieldses.org>
In-Reply-To: <20100707211037.GF2957@fieldses.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/ 7/10 05:10 PM, J. Bruce Fields wrote:
> On Tue, Jul 06, 2010 at 04:53:34PM -0400, Chuck Lever wrote:
>> Some well-known NFSv3 clients drop their directory entry caches when
>> they receive replies with no WCC data.
>
> Can we include any more details?  (And/or a simple test case that
> demonstrates the difference?)

I have a version of this patch with a much more comprehensive 
description which I can post later today.

As for a test case... among other things, I untarred a large tarball on 
a Mac OS 10.6 NFS client, and, once the server was fixed, it went as 
quickly as you would expect.  Before, it took much longer.

>> Without this data, they
>> employ extra READ, LOOKUP, and GETATTR requests to ensure their
>> directory entry caches are up to date, causing performance to suffer
>> needlessly.
>>
>> In order to return WCC data, our server has to have both the pre-op
>> and the post-op attribute data on hand when a reply is XDR encoded.
>> The pre-op data is filled in when the incoming fh is locked, and the
>> post-op data is filled in when the fh is unlocked.
>>
>> Unfortunately, for REMOVE, RMDIR, MKNOD, and MKDIR, the directory fh
>> is not unlocked until well after the reply has been XDR encoded.
>
> So it wasn't happening until an fh_put() was done in .pc_release()?

Correct.
