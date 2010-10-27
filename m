Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og112.obsmtp.com ([64.18.0.24]:41642 "HELO
	exprod5og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932293Ab0J0V3a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Oct 2010 17:29:30 -0400
Message-ID: <4CC899B7.3080904@panasas.com>
Date: Wed, 27 Oct 2010 23:29:27 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] SQUASHME: pnfs: filelayout: print_ds should use dprintk
References: <4CC86D96.8020803@panasas.com>	 <1288203860-26920-1-git-send-email-bhalevy@panasas.com>	 <AANLkTikKpCO_xYjOpj74AiptyDjtMtJJhQaObksF_+LE@mail.gmail.com>	 <4CC8863B.3080504@panasas.com>	 <AANLkTinsRNKCOQZjH4kYTTou-a+J02dM8nB=WL_xu7Wb@mail.gmail.com>	 <4CC892E1.3070703@panasas.com> <1288214583.13431.19.camel@heimdal.trondhjem.org>
In-Reply-To: <1288214583.13431.19.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-27 23:23, Trond Myklebust wrote:
> On Wed, 2010-10-27 at 23:00 +0200, Benny Halevy wrote:
>> On 2010-10-27 22:17, Fred Isaman wrote:
>>> On Wed, Oct 27, 2010 at 4:06 PM, Benny Halevy <bhalevy@panasas.com> wrote:
>>>> On 2010-10-27 21:49, Fred Isaman wrote:
>>>>> The change to printk was in response to Trond's complaint about
>>>>> successive dprintks.
>>>>>
>>>>> Instead, the following would work:
>>>>>
>>>>>
>>>>> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
>>>>> index 5f52e6f..2ce393c 100644
>>>>> --- a/fs/nfs/nfs4filelayout.c
>>>>> +++ b/fs/nfs/nfs4filelayout.c
>>>>> @@ -585,7 +585,8 @@ filelayout_commit(struct nfs_write_data *data, int sync)
>>>>>               }
>>>>
>>>> If we're going this way, the ifdebug could cover the following
>>>> printout as well...
>>>>
>>>
>>> Did you mean preceding printout?  By the way - the complaint about
>>
>> Yeah, preceding the call to print_ds (following my comment :)
>>
>>> successive dprintks was regarding
>>> print_ds_list repeatedly calling print_ds, which at the time used dprintk.
>>
>> Why do we care to optimize the debug case so much?
>> print_ds_list is already calling print_ds inside ifdebug(FACILITY)
>> so the common, non-debug case is optimized correctly. I.e. we don't
>> repeatedly check the debug flag normally.
> 
> It's not about optimizing the debug case. It's about avoiding having to
> check ifdebug(FACILITY) all the time when we're _not_ debugging.

Right, and so we do, as the whole loop in print_ds_list is enclosed
in ifdebug(FACILITY).

Benny

> 
> Trond
> 
