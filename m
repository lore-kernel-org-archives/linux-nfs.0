Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36849 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752387AbdD0Dy7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Apr 2017 23:54:59 -0400
Received: by mail-io0-f194.google.com with SMTP id x86so2623600ioe.3
        for <linux-nfs@vger.kernel.org>; Wed, 26 Apr 2017 20:54:58 -0700 (PDT)
Subject: Re: [PATCH 2/2] NFSv4: Fix callback server shutdown
To: Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: "bfields@redhat.com" <bfields@redhat.com>
References: <20170426155527.92213-1-trond.myklebust@primarydata.com>
 <20170426155527.92213-2-trond.myklebust@primarydata.com>
 <20170426155527.92213-3-trond.myklebust@primarydata.com>
 <1692a8de-1d22-dfdd-d36f-e2b040160e26@gmail.com>
 <1493263484.1401.2.camel@primarydata.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <4275e06f-97c0-b5b9-e71c-db7380d90534@gmail.com>
Date: Thu, 27 Apr 2017 11:54:48 +0800
MIME-Version: 1.0
In-Reply-To: <1493263484.1401.2.camel@primarydata.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 4/27/2017 11:24, Trond Myklebust wrote:
> On Thu, 2017-04-27 at 11:06 +0800, Kinglong Mee wrote:
>>
>> There is only one use of svc_set_num_threads that by nfsd,
>> I'd like to change svc_set_num_threads and update nfsd than add a new
>> function.
> 
> You can't really combine the two methods. Either you choose signals or
> you choose kthread_stop(). The problem is that signals require the
> thread to be able to persist past the nfsd_destroy() (which again
> forces things like nfsd() having to take nfsd_mutex), or you have to
> make things synchronous, in which case having nfsd() try to take
> nfsd_mutex causes deadlocks.
> 
> IOW: if there is legacy behaviour here that requires the signal method,
> then knfsd cannot be converted.

Got it.

Tested-and-reviewed-by: Kinglong Mee <kinglongmee@gmail.com>

thanks,
Kinglong Mee

> 
>> Ps,
>> "NFSv4.x/callback: Create the callback service through
>> svc_create_pooled"
>> must be include before the fix. I will resend it later.
>>
> OK. Thanks!
> 
