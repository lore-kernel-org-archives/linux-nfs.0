From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 036/100] lockd: fix reference count leaks in async
	locking case
Date: Mon, 28 Jan 2008 15:44:47 -0500
Message-ID: <20080128204447.GI16785@fieldses.org>
References: <1201303040-7779-28-git-send-email-bfields@citi.umich.edu> <1201303040-7779-29-git-send-email-bfields@citi.umich.edu> <1201303040-7779-30-git-send-email-bfields@citi.umich.edu> <1201303040-7779-31-git-send-email-bfields@citi.umich.edu> <1201303040-7779-32-git-send-email-bfields@citi.umich.edu> <1201303040-7779-33-git-send-email-bfields@citi.!umich.edu> <1201303040-7779-34-git-send-email-bfields@citi.umi!ch.edu> <1201303040-7779-35-git-send-email-bfields@citi.umich.edu> <1201303040-7779-36-git-send-email-bfields@citi.umich.edu> <CC70187B-9DB5-49EA-8905-51E8D15DC3B7@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Oleg Drokin <green-SOTZviwpzew/JUsKyNonYw@public.gmane.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34155 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751902AbYA1Uot (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 15:44:49 -0500
In-Reply-To: <CC70187B-9DB5-49EA-8905-51E8D15DC3B7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 02:46:41PM -0500, Chuck Lever wrote:
> On Jan 25, 2008, at 6:16 PM, J. Bruce Fields wrote:
>> From: Oleg Drokin <green-SOTZviwpzew/JUsKyNonYw@public.gmane.org>
>>
>> In a number of places where we wish only to translate nlm_drop_reply to
>> rpc_drop_reply errors we instead return early with rpc_drop_reply,
>> skipping some important end-of-function cleanup.
>>
>> This results in reference count leaks when lockd is doing posix  
>> locking
>> on GFS2.
>
> Is Oleg's Signed-off-by: missing?

Oleg?

>
>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>> ---
>>  fs/lockd/svc4proc.c |   20 ++++++++++++--------
>>  fs/lockd/svcproc.c  |   22 +++++++++++++---------
>>  2 files changed, 25 insertions(+), 17 deletions(-)
>
> More below.

White space damaged fixed, thanks.

--b.
