Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:37203 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755015Ab2JVRbv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 13:31:51 -0400
References: <20121022160140.4552.34477.stgit@lebasque.1015granger.net> <5085821C.4020500@RedHat.com>
Mime-Version: 1.0 (1.0)
In-Reply-To: <5085821C.4020500@RedHat.com>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <4E4F3F80-FE31-45E1-A938-1D5DB8E7E64B@oracle.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 00/10] nfs-utils compiler warning clean ups
Date: Mon, 22 Oct 2012 13:31:44 -0400
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The compiler flag that enables a warning is listed in square brackets at the end of each warning message.  Like:  [-wsigned-comparison]

Sent from my iPhone

On Oct 22, 2012, at 1:27 PM, Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 22/10/12 12:05, Chuck Lever wrote:
>> Hi-
>> 
>> These address compiler warnings in mountd and gssd that I've found
>> during recent sojourns in that code base.  I've done some light
>> testing, but more critical review and testing would be appreciated.
>> 
>> I think these are appropriate for your next release of nfs-utils.
> What CFLAGS do you use to see these warnings? Every time I do a build
> I check for warnings and if I would have seen these I would have
> fixed them immediately...   
> 
> BTW, I'm using gcc version 4.7.2 20120921 (Red Hat 4.7.2-2) (GCC)
> to do my builds these days...
> 
> steved.
> 
>> 
>> ---
>> 
>> Chuck Lever (10):
>>      rpc.gssd: Squelch compiler error
>>      rpc.gssd: Squelch compiler warning
>>      rpc.gssd: Squelch compiler warning
>>      mountd: Avoid unnecessary type conversions
>>      mountd: Avoid unnecessary type conversions
>>      mountd: Avoid unnecessary type conversions
>>      mountd: Make local functions static
>>      mountd: Eliminate unnecessary type conversions
>>      mountd: Avoid unnecessary type conversions
>>      nfs-utils: Eliminate dereferencing type punned pointers
>> 
>> 
>> support/include/nfslib.h   |    1 +
>> support/include/sockaddr.h |   10 ++++------
>> support/nfs/cacheio.c      |    5 +++++
>> utils/gssd/gss_util.c      |    2 +-
>> utils/gssd/gssd_proc.c     |   13 +++++++------
>> utils/mountd/cache.c       |   34 ++++++++++++++++++----------------
>> 6 files changed, 36 insertions(+), 29 deletions(-)
>> 
