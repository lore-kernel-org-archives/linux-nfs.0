Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:34653 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbcGKNww convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jul 2016 09:52:52 -0400
Received: by mail-io0-f182.google.com with SMTP id q83so37102574iod.1
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2016 06:52:51 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: RHEL7 hang (and probably mainline) while copying big files because of subrequests merging(?)
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <CACVxJT8GT-ppjdF9k4BB2fzKgWbW6zQyW1DdSTYWVRxhNWDCHA@mail.gmail.com>
Date: Mon, 11 Jul 2016 09:52:49 -0400
Cc: Trond Myklebust <trondmy@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Message-Id: <34912FDB-DC5B-4287-8659-7D95CE848E48@monkey.org>
References: <CACVxJT8fYGqGbHz97xVR1fWtq3YEfQoN7180fEW-Q27UgD=3Ag@mail.gmail.com> <E70C1354-A1F7-47F3-A810-344BA5BE51AB@primarydata.com> <CACVxJT8GT-ppjdF9k4BB2fzKgWbW6zQyW1DdSTYWVRxhNWDCHA@mail.gmail.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 11, 2016, at 9:47 AM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
> 
> On Mon, Jul 11, 2016 at 4:28 PM, Trond Myklebust
> <trondmy@primarydata.com> wrote:
>> 
>>> On Jul 11, 2016, at 08:59, Alexey Dobriyan <adobriyan@gmail.com> wrote:
>>> 
>>> We have a customer who was able to reliably reproduce the following hang:
>>> (hang itself is rare but there are many machines, so it is not rare)
>>> 
>>> INFO: task ascp:66692 blocked for more than 120 seconds.
>> 
>> Why is this being reported here and not to Red Hat? Is the bug reproducible on the upstream kernel?
> 
> It is not a report per se, more heads up for other folks like CentOS
> and other rebuilders.
> I checked every NFS commit since 3.10, there seems to be nothing fixing it.
> As for testing mainline, I don't know, maybe we can arrange that.
> 
>   Alexey
> 

How have you checked every commit since 3.10 and not tested "mainline"?

I don't get how both can be true. Do you mean you manually inspected each
commit? I'm not sure the fix would be so obvious...

-dros

