From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 5/5] NFS: clear fsinfo before sendign rpc
Date: Wed, 13 Oct 2010 17:27:53 -0400
Message-ID: <4CB62459.50006@panasas.com>
References: <4CA31DC3.8070300@panasas.com>	 <1285758613-26897-1-git-send-email-bhalevy@panasas.com>	 <AANLkTim8BCOgLNXZt3QKLX=g1dEruNEWHsb2GPs2AVYD@mail.gmail.com>	 <4CB617ED.4000504@panasas.com>	 <1287003279.3015.205.camel@heimdal.trondhjem.org>	 <4CB62105.2040908@panasas.com> <1287004813.3015.212.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og103.obsmtp.com ([64.18.0.145]:35777 "HELO
	exprod5og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751523Ab0JMV1z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Oct 2010 17:27:55 -0400
In-Reply-To: <1287004813.3015.212.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-10-13 17:20, Trond Myklebust wrote:
> On Wed, 2010-10-13 at 17:13 -0400, Benny Halevy wrote:
>> On 2010-10-13 16:54, Trond Myklebust wrote:
>>> On Wed, 2010-10-13 at 16:34 -0400, Benny Halevy wrote:
>>>> On 2010-10-13 14:03, Fred Isaman wrote:
>>>>> On Wed, Sep 29, 2010 at 7:10 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>>>>>> To initialize all values to zero, in case the server or protocol version
>>>>>> do no support particular attributes.
>>>>>
>>>>> Sorry for the delayed response, but...
>>>>>
>>>>> Zero is not an appropriate default for many of the values.  Further,
>>>>> decode_fsinfo sets a default for each value, even in cases where the
>>>>> server or protocol version do not support particular attributes.  So
>>>>> this patch seems to server no purpose.
>>>>
>>>> Note that nfs_probe_fsinfo is called also for nfs version 2 and 3
>>>> and these don't know anything about nfsv4.1 attributes so they can't
>>>> cannot explicitly set them to any default value.
>>>
>>> Err... Why would we care? Under exactly what circumstances would we want
>>> generic code to be processing fsinfo attributes that are specific only
>>> to NFSv4.1?
>>>
>>> Trond
>>
>> Originally, set_pnfs_layoutdriver, was called only for nfsv4.1
>> but we changed it to always be called in nfs_server_set_fsinfo()
> 
> So it relies on a flag in the fsinfo structure to tell it that this is a
> pNFS-capable server? That's fine, but in that case, you should perhaps
> explicitly initialise that flag to the non-pNFS capable value in the
> generic code.
> We shouldn't need to zero out the entire structure.

OK. That's possible.

Benny

> 
> Cheers
>   Trond
