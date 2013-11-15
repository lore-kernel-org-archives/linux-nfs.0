Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:26740 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362Ab3KORHQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 12:07:16 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] NFS: -EIO from decode_bitmap if too many bitmaps
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1384535149.4046.13.camel@leira.trondhjem.org>
Date: Fri, 15 Nov 2013 12:07:13 -0500
Cc: Weston Andros Adamson <dros@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <C9A7EFC4-6B93-44D4-8ADC-AAC440D4CFB2@oracle.com>
References: <1384533481-2254-1-git-send-email-dros@netapp.com> <1384534841.4046.11.camel@leira.trondhjem.org> <1384535149.4046.13.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 15, 2013, at 12:05 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2013-11-15 at 12:00 -0500, Trond Myklebust wrote:
>> On Fri, 2013-11-15 at 11:38 -0500, Weston Andros Adamson wrote:
>>> decode_bitmap will only decode up to three bitmaps.  If the xdr buffer
>>> has more than three bitmaps, return -EIO here instead of bailing out in
>>> a later xdr decode.
>>> 
>> 
>> No. decode_bitmap will only _save_ 3 words in the bitmap[] argment, but
>> it will decode arbitrary sized bitmaps:
>> 
>> 	p = xdr_inline_decode(xdr, (bmlen << 2));
>> 
> 
> That said, we should probably check that the server isn't setting those
> bitmap words to any non-zero values. That would be a reason to return
> EIO.

Why wouldn't the client simply warn and ignore the extraneous data?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




