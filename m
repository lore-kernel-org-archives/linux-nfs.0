Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35466 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030311AbcGKNrn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jul 2016 09:47:43 -0400
Received: by mail-wm0-f48.google.com with SMTP id f65so64033639wmi.0
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2016 06:47:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <E70C1354-A1F7-47F3-A810-344BA5BE51AB@primarydata.com>
References: <CACVxJT8fYGqGbHz97xVR1fWtq3YEfQoN7180fEW-Q27UgD=3Ag@mail.gmail.com>
 <E70C1354-A1F7-47F3-A810-344BA5BE51AB@primarydata.com>
From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 11 Jul 2016 16:47:41 +0300
Message-ID: <CACVxJT8GT-ppjdF9k4BB2fzKgWbW6zQyW1DdSTYWVRxhNWDCHA@mail.gmail.com>
Subject: Re: RHEL7 hang (and probably mainline) while copying big files
 because of subrequests merging(?)
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        Weston Andros Adamson <dros@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 11, 2016 at 4:28 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
>
>> On Jul 11, 2016, at 08:59, Alexey Dobriyan <adobriyan@gmail.com> wrote:
>>
>> We have a customer who was able to reliably reproduce the following hang:
>> (hang itself is rare but there are many machines, so it is not rare)
>>
>> INFO: task ascp:66692 blocked for more than 120 seconds.
>
> Why is this being reported here and not to Red Hat? Is the bug reproducible on the upstream kernel?

It is not a report per se, more heads up for other folks like CentOS
and other rebuilders.
I checked every NFS commit since 3.10, there seems to be nothing fixing it.
As for testing mainline, I don't know, maybe we can arrange that.

   Alexey
