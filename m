Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35298 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493Ab1D0EuS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Apr 2011 00:50:18 -0400
Message-ID: <4DB7A084.2060009@panasas.com>
Date: Wed, 27 Apr 2011 07:50:12 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsstat: reorder nfs4 stats for 2.6.38 and up
References: <1303461980-6731-1-git-send-email-bhalevy@panasas.com> <23EF6F61-46F2-431B-8A44-A3E941688D65@oracle.com>
In-Reply-To: <23EF6F61-46F2-431B-8A44-A3E941688D65@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-04-25 17:11, Chuck Lever wrote:
> Hey all-
> 
> So what are we going to do when adding NFSv4.2 to this mix?  Will we
> then have to freeze both the NFSv4.1 and NFSv4.0 procedure API in the
> kernel?  Seems painful.

Good question.
How about changing the stat pseudo-file format to include an op
identifier along with its respective counter, printing a line per op?

Benny

> 
> On Apr 22, 2011, at 4:46 AM, Benny Halevy wrote:
> 
>> match order in 2.6.38, 2.6.39 (-rc3) and development tree while at
>> it, get rid of obsolete ds_write and ds_commit
>> 
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com> --- 
>> utils/nfsstat/nfsstat.c |    5 +---- 1 files changed, 1
>> insertions(+), 4 deletions(-)
>> 
>> git://linux-nfs.org/~bhalevy/pnfs-nfs-utils.git updated
>> respectively
>> 
>> diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c 
>> index f31bb81..a4a8034 100644 --- a/utils/nfsstat/nfsstat.c +++
>> b/utils/nfsstat/nfsstat.c @@ -126,14 +126,11 @@ static const char *
>> nfscltproc4name[CLTPROC4_SZ] = { "sequence", "get_lease_t", 
>> "reclaim_comp", +	"getdevinfo", "layoutget", "layoutcommit", 
>> "layoutreturn", "getdevlist", -	"getdevinfo", -	/* nfsv4.1 pnfs
>> client ops to data server only */ -	"ds_write", -	"ds_commit", };
>> 
>> static const char *     nfssrvproc4opname[SRVPROC4OPS_SZ] = { -- 
>> 1.7.3.4
>> 
>> -- To unsubscribe from this list: send the line "unsubscribe
>> linux-nfs" in the body of a message to majordomo@vger.kernel.org 
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

