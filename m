Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:35291 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031293Ab2HIPts convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 11:49:48 -0400
Received: by pbbrr13 with SMTP id rr13so1087695pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Aug 2012 08:49:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9380987@SACEXCMBX04-PRD.hq.netapp.com>
References: <CABpMAyL-B9Kqg8O4xxxtj0X8PF7fP4TM+NnLA_Ynhm-_3C6MUg@mail.gmail.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9380987@SACEXCMBX04-PRD.hq.netapp.com>
From: Idan Kedar <idank@tonian.com>
Date: Thu, 9 Aug 2012 18:49:07 +0300
Message-ID: <CABpMAyKddCjhWe-LjFOJrikLnC+BJ7GsAMAvieh1rabDPiA=Ug@mail.gmail.com>
Subject: Re: return layout on error, BUG/deadlock
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        Benny Halevy <bhalevy@tonian.com>, Peng Tao <bergwolf@gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 9, 2012 at 5:05 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>> owner@vger.kernel.org] On Behalf Of Idan Kedar
>> Sent: Thursday, August 09, 2012 9:03 AM
>> To: Boaz Harrosh; NFS list
>> Cc: Benny Halevy
>> Subject: return layout on error, BUG/deadlock
>>
>> Hi,
>>
>> As a result of some experiments, I wanted to see what happens when I
>> inject an error (hard coded) to the object layout driver. the patch is at the
>> bottom of this mail. the reason I did this is because when I inject errors in my
>> modified version of the object layout driver, I get the same BUG Tigran
>> reported about yesterday:
>> nfs4proc.c:6252 :   BUG_ON(!list_empty(&lo->plh_segs));
>>
>> In my modified version (based on kernel 3.3), the bug seems to be that
>> pnfs_ld_write_done calls pnfs_return_layout in the error path, even if there
>> is in-flight I/O.
>
> That is not a bug. It is an intentional change in order to allow the MDS to fence off the outstanding writes (if it can do so) before we retransmit them as write-through-MDS. Otherwise, you risk races between the outstanding writes-to-DS and the new writes-through-MDS.

to what change are you referring?

>
> See the changelog in the patch that I sent to the list yesterday.
>

I saw that, and if I'm not mistaken these races apply to object layout
as well, and in any case they apply in my case. However, it is not
easy to mess around with LAYOUTRETURN in object layout, and there have
been several discussions on the issue. In one of these discussions
Benny clarified that the object layout client must wait for all
in-flight I/O to end.
So for file layout it probably makes sense, but object layout (and if
I understand correctly, block layout as well) something else needs to
be done. I thought about sync wait when returning the layout on error,
but according to Boaz it will cause deadlocks (Boaz - can you please
elaborate?).
And come to think of it, nfs4_proc_setattr also returns the layout
when there may be I/O in-flight (correct me if i'm wrong). So I guess
pnfs_return_layout should somehow solve this by itself by saying "if
this is fencing (a flag which will be set for file layout only), go
ahead, otherwise make the layout as 'needs to be returned' and when
the lseg lists gets empty return the layout".
Comments?

> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
>

-- 
idank
