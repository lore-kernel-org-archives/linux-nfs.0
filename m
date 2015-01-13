Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx144.netapp.com ([216.240.21.25]:27748 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751058AbbAMTvn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Jan 2015 14:51:43 -0500
Message-ID: <54B5774D.7030907@Netapp.com>
Date: Tue, 13 Jan 2015 14:51:41 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Tom Haynes <thomas.haynes@primarydata.com>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 42/49] nfs41: add range to layoutreturn args
References: <1420590534-84063-1-git-send-email-loghyr@primarydata.com> <1420590534-84063-43-git-send-email-loghyr@primarydata.com> <54B56EB8.2060703@Netapp.com> <20150113194245.GB90833@kitty>
In-Reply-To: <20150113194245.GB90833@kitty>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/13/2015 02:42 PM, Tom Haynes wrote:
> On Tue, Jan 13, 2015 at 02:15:04PM -0500, Anna Schumaker wrote:
>> Hi Tao,
>>
>> On 01/06/2015 07:28 PM, Tom Haynes wrote:
>>> From: Peng Tao <tao.peng@primarydata.com>
>>>
>>> -	lrp->args.iomode = iomode;
>>> +	lrp->args.range.iomode = iomode;
>>> +	lrp->args.range.offset = offset;
>>> +	lrp->args.range.length = length;
>>
>> Callers of pnfs_send_layoutreturn() are always passing offset = 0 and length = NFS4_MAX_UINT64.  Can we have pnfs_send_layoutreturn() always set these values, rather than passing them as function parameters?
>>
> 
> Hi Anna,
> 
> This is future-proofing - i.e., add the parameters such
> that when we allow only returning part of the file we
> already have the support in place.

I still think we should hold off until partial file returns are added, making it less likely that somebody will introduce a bug in the meantime.

Anna

> 
> Thanks,
> Tom
> 

