Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([209.166.131.148]:35655 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbaANWWL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jan 2014 17:22:11 -0500
Message-ID: <52D5B886.6000803@panasas.com>
Date: Wed, 15 Jan 2014 00:21:58 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: NFS list <linux-nfs@vger.kernel.org>, Stable Tree <stable@vger.kernel.org>
Subject: Re: [PATCH v2] pnfs: Proper delay for NFS4ERR_RECALLCONFLICT in layout_get_done
References: <52D5589A.7090507@panasas.com> <1389726356.6420.5.camel@leira.trondhjem.org>
In-Reply-To: <1389726356.6420.5.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/14/2014 09:05 PM, Trond Myklebust wrote:
> On Tue, 2014-01-14 at 17:32 +0200, Boaz Harrosh wrote:
>>  
> 
> For the default mount option of 'timeo=600', and the default #define
> NFS4_POLL_RETRY_MIN==HZ/10, this means we can end up pounding the server
> with 600 LAYOUTGET requests within the space of 1 minute, before giving
> up. Is that reasonable?
> 

It will never get there it will always be 1 or two sends. Usually it is
just so the sequence of layout_get_done is out of the way and the
LAYOUT_RECALL sequence+1 can get through and the layout released. Then
the next time it will all be good and the LAYOUT_GET will succeed.

Worst case is when the client is very busy with queue full of IO
on the same busy layout that needs to be released by the recall. Personally
I found that this never exceeds 40 IOPs in flight. Note that this is not
the amount of total dirty memory but only the amount of already submitted
IO. I guess that on a very slow connection these can take time but in
regular line speeds I never observed more the 2 retries with this patch.

It is all up to the client. NFS4ERR_RECALLCONFLICT means "the layouts you
have need to be released" (I say released because the forgetful model does
not actually returns them). Can you see a critical time when layouts are
held for longer than a second ?

Thanks
Boaz

