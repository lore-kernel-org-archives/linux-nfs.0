From: Steve Dickson <SteveD@redhat.com>
Subject: Re: RFC: Is SM_SIMU_CRASH (in rpc.statd) needed?
Date: Tue, 22 Jun 2010 12:33:27 -0400
Message-ID: <4C20E5D7.80908@RedHat.com>
References: <4C20CA12.2070002@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFSv3 list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57851 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751515Ab0FVQ4T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jun 2010 12:56:19 -0400
In-Reply-To: <4C20CA12.2070002@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/22/2010 10:34 AM, Chuck Lever wrote:
>> Does anybody know who uses SM_SIMU_CRASH and is it
>> still needed? I'm getting some push back from our
>> security folks to plug this DoS hole up...
> 
> How is it a DoS?  statd ignores any SM_SIMU_CRASH from a non-loopback
> address that does not use a privileged port.  To invoke it, you
> basically have to be a privileged local user.
It happens during an ISS scan....

> 
> Right now, no one uses it, but I think we should reserve the right to
> use it in the future.  This could be part of a more robust interface
> between lockd and statd.
hmm... how can having a way of bringing down a daemon, make it more robust?

steved.

