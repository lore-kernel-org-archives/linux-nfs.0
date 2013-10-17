Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:36214 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758642Ab3JQTgE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 15:36:04 -0400
Message-ID: <52603C22.5050009@candelatech.com>
Date: Thu, 17 Oct 2013 12:36:02 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 'umount -f /mnt/foo' fails if server IP is gone.
References: <525D899F.5010604@candelatech.com>    <52601FED.6070708@candelatech.com>   <1382033137.3216.3.camel@leira.trondhjem.org>   <52602835.4000701@candelatech.com>  <1382034747.3216.8.camel@leira.trondhjem.org>  <52602DD7.6050708@candelatech.com> <1382035346.3216.15.camel@leira.trondhjem.org> <52603BAF.2030209@candelatech.com>
In-Reply-To: <52603BAF.2030209@candelatech.com>
Content-Type: text/plain; charset=UTF-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/17/2013 12:34 PM, Ben Greear wrote:

> After cable is reconnected, (and with btserver process still hung),
> I tried to re-mount the same partition.  Those mount calls are hanging
> as well.
> 
> So, maybe some progress, but I think there are still some fixes needed.

About the time I finished composing this email and sent it, it appears
everything cleaned up.  So, maybe not quite as bad as it first looked,
but still room for improvement in my opinion.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

