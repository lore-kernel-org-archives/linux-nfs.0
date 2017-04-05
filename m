Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44144 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752869AbdDER3r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Apr 2017 13:29:47 -0400
Subject: Re: [PATCH 1/2] nfsd: Allow the caller to turn off NFSv4.0 without
 turning off NFSv4.x
To: Trond Myklebust <trondmy@primarydata.com>
References: <20170224003344.113724-1-trond.myklebust@primarydata.com>
 <20170224003344.113724-2-trond.myklebust@primarydata.com>
 <1ec88fba-7bdb-ee59-e4cf-20970f45bd1d@RedHat.com>
 <1491337561.14806.1.camel@primarydata.com>
 <4d26d8f6-74af-9225-d98d-6e2c42a22e09@RedHat.com>
 <4B984CF4-7D50-4B11-B26E-886845068329@primarydata.com>
 <4a409f78-9dfb-cfa4-67e7-6c67b8d263ac@RedHat.com>
Cc: James Bruce Fields <bfields@fieldses.org>,
        "neilb@suse.com" <neilb@suse.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <e132765d-8474-b9fb-9df1-2a296884d236@RedHat.com>
Date: Wed, 5 Apr 2017 13:29:39 -0400
MIME-Version: 1.0
In-Reply-To: <4a409f78-9dfb-cfa4-67e7-6c67b8d263ac@RedHat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/04/2017 05:31 PM, Steve Dickson wrote:
>>> But I'm thinking the expectation of nfsd -N4.0 is to only 
>>> turn off v4.0 and not work the same as -N4 which turns all of
>>> v4 off which is expected. 
>>>
>>> When you say old kernel... How old?
>> Linux 4.10 or older.
> So what will happen when this is done
>     nfsd -d -N4.0 -V4.1 -V4.2
> on an older kernel?
On an older kernel this turns off all v4 minor version.
Plus on older kernels you can turn v4.1 and v4.2 on
and off but as soon as v4 or v4.0 is turned off
all versions are off...

With newer kernels things work as expected. 

Committed... 

steved.

> 
> Also looking at the code when -N4.0 is used
> it zero out the entire minorversset which means 
> the -4.1 and -4.2 is not written out to the versions file
> 
> nfsd -d -N4
> nfsd: Writing version string to kernel: -2 +3 -4 -4.1 -4.2
> 
> nfsd -d -N4.0
> nfsd: Writing version string to kernel: -2 +3 -4
> 
> I'm not sure if this matters or not... but it is different.
> 
> steved.
