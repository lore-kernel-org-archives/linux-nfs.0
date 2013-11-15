Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:9023 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751783Ab3KORWP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 12:22:15 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: -EIO from decode_bitmap if too many bitmaps
Date: Fri, 15 Nov 2013 17:22:07 +0000
Message-ID: <D5B7F898-04F4-40DB-92E2-F013339CBA4B@netapp.com>
References: <1384533481-2254-1-git-send-email-dros@netapp.com>
 <1384534841.4046.11.camel@leira.trondhjem.org>
 <1384535149.4046.13.camel@leira.trondhjem.org>
 <C9A7EFC4-6B93-44D4-8ADC-AAC440D4CFB2@oracle.com>
 <1384535424.4046.15.camel@leira.trondhjem.org>
In-Reply-To: <1384535424.4046.15.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 15, 2013, at 12:10 PM, Myklebust, Trond <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2013-11-15 at 12:07 -0500, Chuck Lever wrote:
>> On Nov 15, 2013, at 12:05 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>> 
>>> On Fri, 2013-11-15 at 12:00 -0500, Trond Myklebust wrote:
>>>> On Fri, 2013-11-15 at 11:38 -0500, Weston Andros Adamson wrote:
>>>>> decode_bitmap will only decode up to three bitmaps.  If the xdr buffer
>>>>> has more than three bitmaps, return -EIO here instead of bailing out in
>>>>> a later xdr decode.
>>>>> 
>>>> 
>>>> No. decode_bitmap will only _save_ 3 words in the bitmap[] argment, but
>>>> it will decode arbitrary sized bitmaps:
>>>> 
>>>> 	p = xdr_inline_decode(xdr, (bmlen << 2));
>>>> 

Oh, yeah.

>>> 
>>> That said, we should probably check that the server isn't setting those
>>> bitmap words to any non-zero values. That would be a reason to return
>>> EIO.

Ok, I’ll rework this.

-dros

>> 
>> Why wouldn't the client simply warn and ignore the extraneous data?
>> 
> 
> ...because unless the GETATTR is the very last operation, we'd end up
> failing to decode things correctly. Anyway, a server that returns
> attributes that we haven't requested must clearly be borken. It's
> definitely violating the spec.
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

