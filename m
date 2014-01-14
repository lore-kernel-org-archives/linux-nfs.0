Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:36009 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbaANWnl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jan 2014 17:43:41 -0500
Received: by mail-ie0-f181.google.com with SMTP id at1so1262396iec.40
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jan 2014 14:43:41 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH v2] pnfs: Proper delay for NFS4ERR_RECALLCONFLICT in layout_get_done
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <52D5B886.6000803@panasas.com>
Date: Tue, 14 Jan 2014 17:43:37 -0500
Cc: NFS list <linux-nfs@vger.kernel.org>, Stable Tree <stable@vger.kernel.org>
Message-Id: <42EE44E9-1051-4D22-A4B6-D7E70A59ED2D@primarydata.com>
References: <52D5589A.7090507@panasas.com> <1389726356.6420.5.camel@leira.trondhjem.org> <52D5B886.6000803@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 14, 2014, at 17:21, Boaz Harrosh <bharrosh@panasas.com> wrote:

> On 01/14/2014 09:05 PM, Trond Myklebust wrote:
>> On Tue, 2014-01-14 at 17:32 +0200, Boaz Harrosh wrote:
>>> 
>> 
>> For the default mount option of 'timeo=600', and the default #define
>> NFS4_POLL_RETRY_MIN==HZ/10, this means we can end up pounding the server
>> with 600 LAYOUTGET requests within the space of 1 minute, before giving
>> up. Is that reasonable?
>> 
> 
> It will never get there it will always be 1 or two sends. Usually it is
> just so the sequence of layout_get_done is out of the way and the
> LAYOUT_RECALL sequence+1 can get through and the layout released. Then
> the next time it will all be good and the LAYOUT_GET will succeed.
> 
> Worst case is when the client is very busy with queue full of IO
> on the same busy layout that needs to be released by the recall. Personally
> I found that this never exceeds 40 IOPs in flight. Note that this is not
> the amount of total dirty memory but only the amount of already submitted
> IO. I guess that on a very slow connection these can take time but in
> regular line speeds I never observed more the 2 retries with this patch.
> 
> It is all up to the client. NFS4ERR_RECALLCONFLICT means "the layouts you
> have need to be released" (I say released because the forgetful model does
> not actually returns them). Can you see a critical time when layouts are
> held for longer than a second ?

That will probably depend on the workload and possibly on the layout type.

My point was, however, about the potential for mischief due to the mismatch between the number of retries that the resulting code allows, and the fixed period between those retries of 1/10 seconds. Why not rather use something along the lines of "rpc_delay(rpc_task, min(giveup -jiffies , max(jiffies - lgp->args.timestamp, NFS4_POLL_RETRY_MIN)));”? That gives you an initially exponential back off with a minimum period of NFS4_POLL_RETRY_MIN, and with an expiry date of ‘timeo’ jiffies after the first attempt.

--
Trond Myklebust
Linux NFS client maintainer

