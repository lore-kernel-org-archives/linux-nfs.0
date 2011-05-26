Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:21663 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757385Ab1EZOpT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 10:45:19 -0400
Message-ID: <4DDE6783.5@panasas.com>
Date: Thu, 26 May 2011 17:45:23 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Benny Halevy <bhalevy@panasas.com>, Fred Isaman <iisaman@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] pnfs: Send layoutreturn, if Return-On-Close is set
References: <4DDE536E.8020805@panasas.com> <1306419397.2984.14.camel@lade.trondhjem.org>
In-Reply-To: <1306419397.2984.14.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/26/2011 05:16 PM, Trond Myklebust wrote:
> On Thu, 2011-05-26 at 16:19 +0300, Boaz Harrosh wrote: 
>> Every thing was ready, in pnfs_roc(). The segments released
>> and the LO state blocked til after the close is done. All that
>> is needed is to send the actual layoutreturn synchronously.
> 
> Why would we want to do this?
> 
> Return-on-close was initially considered useful only for debugging.
> 
What ??

> At the interim IETF meeting in Sunnyvale, we also discussed the case
> where the forgetful client has forgotten the layout: in this case the
> server may decide to forget the layout too. There is no controversy in
> doing this, since both the client and the server know that any
> outstanding layout is supposed to be returned (and if there is a
> problem, then the server always has the option of sending a
> CB_LAYOUTRECALL).
> 

OK I didn't know that. So what you are saying is that if the server see
a final close he can go and provocative free all segments marked with ROC?

If so then someone should fix the Linux server. Because currently it never
frees them. On a modest machine like the UML I use. Few 10s of "git checkout linux"
crash the machine with oom. Today they are only freed on client umount.

> Adding a synchronous call to close is in any case a bug since close can
> on occasion be sent in situations where we don't allow sleeping.
> 

This is done only on the final close. Isn't the very final call sync?

Ok re-inspecting the code I can see that nfs4_do_close also takes a wait flag.
I thought that the last close should always be waiting for all operations
to end before proceeding with the close. That's how it is at the VFS level
but I guess life is hard. So the only possible solution is within the same
compound as the close. (not that we need it as you say)

> Cheers
>   Trond

Thanks
Boaz
