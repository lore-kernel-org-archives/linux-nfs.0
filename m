Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:64633 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759044Ab0HDVVT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 17:21:19 -0400
Received: by gxk23 with SMTP id 23so2177985gxk.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Aug 2010 14:21:19 -0700 (PDT)
In-Reply-To: <1280956170.2865.6.camel@heimdal.trondhjem.org>
References: <AANLkTi=2KYZ-8qaXMG=C_s617q3k1Ocs7h1gyd8=RpY6@mail.gmail.com>
	<AANLkTimr9QfF0+MJ47hUihJgSLVOfquR=Atp4iV5D2gr@mail.gmail.com>
	<1280956170.2865.6.camel@heimdal.trondhjem.org>
From: Yudong Gao <stgyd@umich.edu>
Date: Wed, 4 Aug 2010 14:20:59 -0700
Message-ID: <AANLkTikWLmF8hq2iPV39TwHLyGVRz0qovuNbM1F08YVd@mail.gmail.com>
Subject: Re: Write delegation
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I see. That makes sense. I think in most case the file open delegation
will be enough. It seems to me that the directory data is at least as
critical as the file meta data such as file attributes. This kind of
data, in most cases, should be propagated to the server as soon as
possible. Not sure whether this argument makes sense. :P

Thanks!

best,

Yudong

On Wed, Aug 4, 2010 at 2:09 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Wed, 2010-08-04 at 12:21 -0700, Yudong Gao wrote:
>> Hi,
>>
>> I am not able to find the implementation of directory delegation,
>> either. Similarly, the callback functions CB_NOTIFY is not
>> implemented, either. I find that in preprocss_nfs41_op() in
>> callback_xdr.c, whenever a CB_NOTIFY is encountered, an
>> NFS4ERR_NOTSUPP is returned directly.
>>
>> Am I missing something? Or they are just not supported in the current version?
>
> The client currently does not request any directory delegations or
> notifications, so there is no reason for it to support CB_NOTIFY.
>
> Maybe we will add support for directory delegations and notifications at
> some time in the future, but before that happens, somebody needs to
> convince me that they are useful. Currently there is very little
> documentation to support any assertion that they are...
>
> Cheers
>  Trond
>
>
