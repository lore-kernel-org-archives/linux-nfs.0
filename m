Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:44340 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758537Ab0HDVJf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Aug 2010 17:09:35 -0400
Subject: Re: Write delegation
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Yudong Gao <stgyd@umich.edu>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTimr9QfF0+MJ47hUihJgSLVOfquR=Atp4iV5D2gr@mail.gmail.com>
References: <AANLkTi=2KYZ-8qaXMG=C_s617q3k1Ocs7h1gyd8=RpY6@mail.gmail.com>
	 <AANLkTimr9QfF0+MJ47hUihJgSLVOfquR=Atp4iV5D2gr@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 04 Aug 2010 17:09:30 -0400
Message-ID: <1280956170.2865.6.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-08-04 at 12:21 -0700, Yudong Gao wrote:
> Hi,
> 
> I am not able to find the implementation of directory delegation,
> either. Similarly, the callback functions CB_NOTIFY is not
> implemented, either. I find that in preprocss_nfs41_op() in
> callback_xdr.c, whenever a CB_NOTIFY is encountered, an
> NFS4ERR_NOTSUPP is returned directly.
> 
> Am I missing something? Or they are just not supported in the current version?

The client currently does not request any directory delegations or
notifications, so there is no reason for it to support CB_NOTIFY.

Maybe we will add support for directory delegations and notifications at
some time in the future, but before that happens, somebody needs to
convince me that they are useful. Currently there is very little
documentation to support any assertion that they are...

Cheers
  Trond

