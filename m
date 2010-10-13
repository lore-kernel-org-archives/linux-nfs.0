Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og110.obsmtp.com ([64.18.0.20]:43954 "HELO
	exprod5og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752434Ab0JMVNm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Oct 2010 17:13:42 -0400
Message-ID: <4CB62105.2040908@panasas.com>
Date: Wed, 13 Oct 2010 17:13:41 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 5/5] NFS: clear fsinfo before sendign rpc
References: <4CA31DC3.8070300@panasas.com>	 <1285758613-26897-1-git-send-email-bhalevy@panasas.com>	 <AANLkTim8BCOgLNXZt3QKLX=g1dEruNEWHsb2GPs2AVYD@mail.gmail.com>	 <4CB617ED.4000504@panasas.com> <1287003279.3015.205.camel@heimdal.trondhjem.org>
In-Reply-To: <1287003279.3015.205.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-13 16:54, Trond Myklebust wrote:
> On Wed, 2010-10-13 at 16:34 -0400, Benny Halevy wrote:
>> On 2010-10-13 14:03, Fred Isaman wrote:
>>> On Wed, Sep 29, 2010 at 7:10 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>>>> To initialize all values to zero, in case the server or protocol version
>>>> do no support particular attributes.
>>>
>>> Sorry for the delayed response, but...
>>>
>>> Zero is not an appropriate default for many of the values.  Further,
>>> decode_fsinfo sets a default for each value, even in cases where the
>>> server or protocol version do not support particular attributes.  So
>>> this patch seems to server no purpose.
>>
>> Note that nfs_probe_fsinfo is called also for nfs version 2 and 3
>> and these don't know anything about nfsv4.1 attributes so they can't
>> cannot explicitly set them to any default value.
> 
> Err... Why would we care? Under exactly what circumstances would we want
> generic code to be processing fsinfo attributes that are specific only
> to NFSv4.1?
> 
> Trond

Originally, set_pnfs_layoutdriver, was called only for nfsv4.1
but we changed it to always be called in nfs_server_set_fsinfo()

Benny
