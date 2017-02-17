Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:6246 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934271AbdBQVQF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Feb 2017 16:16:05 -0500
Subject: Re: [PATCH 0/7] Some cleanups and updates for sunrpc
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        Trond Myklebust <trondmy@primarydata.com>
References: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
 <20170217170313.GA9791@fieldses.org>
 <1487352262.11929.4.camel@primarydata.com>
 <20170217190926.GC10894@fieldses.org>
CC: "kinglongmee@gmail.com" <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <d51176f4-3e13-7a26-1faa-7ac254e2f1f9@Netapp.com>
Date: Fri, 17 Feb 2017 16:15:56 -0500
MIME-Version: 1.0
In-Reply-To: <20170217190926.GC10894@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

On 02/17/2017 02:09 PM, bfields@fieldses.org wrote:
> On Fri, Feb 17, 2017 at 05:25:04PM +0000, Trond Myklebust wrote:
>> On Fri, 2017-02-17 at 12:03 -0500, J. Bruce Fields wrote:
>>> Thanks, these look fine to me.
>>>
>>> It's really a mixture of client- and server- side stuff, but seems
>>> unlikely to have serious conflicts with either.  For simplicity's
>>> sake I
>>> think I'll just take them, unless Trond tells me he has.
>>>
>>
>> Anna is managing the merge window for the odd-numbered kernel releases
>> (Cced).
> 
> Got it, thanks.  Anna, I've currently got this queued up in my tree, but
> let me know if that's a problem.

I have everything applied to my tree, but I don't mind if you want to take all the patches :)

> 
> (This every-other-kernel scheme would be easier for me to remember if
> only one of you was clearly odder than the other.  But I think you're
> about equally odd.)

Well, I guess I could try to find even more weird hobbies ...

> 
> --b.
> 
