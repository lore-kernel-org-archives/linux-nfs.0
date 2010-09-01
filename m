Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6397 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779Ab0IAEUj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Sep 2010 00:20:39 -0400
Subject: Re: fsync/wb deadlocks in 2.6.32
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Lameter <cl@linux.com>
Cc: Kian Mohageri <kian.mohageri@gmail.com>, davidr@ressman.org,
        linux-nfs@vger.kernel.org
In-Reply-To: <alpine.DEB.2.00.1008310934150.867@router.home>
References: <AANLkTikWR_YSnx=4=KAodATpX+xO9+hj-cf7_e158f4d@mail.gmail.com>
	 <AANLkTi=gj901aF_84+40j9MhvAwNJSNB8qRnpY8o0gBZ@mail.gmail.com>
	 <AANLkTinEoMgXLvN4MvfnCHjHtHCwV1HDP67BoKQ3ZbQx@mail.gmail.com>
	 <alpine.DEB.2.00.1008301101560.10316@router.home>
	 <AANLkTinieSM_-x4qra7_HOCsONFAdyjn3LQbyBDJRebT@mail.gmail.com>
	 <alpine.DEB.2.00.1008310934150.867@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Sep 2010 00:20:32 -0400
Message-ID: <1283314832.5220.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-08-31 at 09:36 -0500, Christoph Lameter wrote:
> We got another instance yesterday. A large number of machines
> simultaneously started spewing the kernel messages. Had to reboot to get
> the state cleared up. Very very annoying. Anyone know a reason for these
> writeback deadlocks?
> 

Hi Christoph,

>From what I could see in your original email to me, you appear to be
using NFS over UDP on IPoIB on a 2.6.32-18 kernel. Is that still the
case? If so, does anything change if you change to use TCP and/or an
ordinary NIC?

Your link to https://bugs.launchpad.net/ubuntu/+source/linux/+bug/561210
appears to be the kswapd bug, which should be hacked around in later
2.6.32 stable versions.

Cheers
  Trond
