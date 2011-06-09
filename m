Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39546 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757368Ab1FIXsy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 19:48:54 -0400
Message-ID: <4DF15BE4.6080709@candelatech.com>
Date: Thu, 09 Jun 2011 16:48:52 -0700
From: Ben Greear <greearb@candelatech.com>
To: Steve Dickson <SteveD@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfs-utils:  Support binding to source address.
References: <1307574083-27608-1-git-send-email-greearb@candelatech.com> <4DF10053.9050901@RedHat.com> <4DF102E0.5000201@candelatech.com> <4DF13842.1020307@RedHat.com> <4DF13A43.6020500@candelatech.com>
In-Reply-To: <4DF13A43.6020500@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/09/2011 02:25 PM, Ben Greear wrote:
> On 06/09/2011 02:16 PM, Steve Dickson wrote:

> How about an initial patch that just passes a container down
> to the bind logic with the 'sap' and 'salen' into a container struct.
>
> Should have zero functionality change, but fairly large patch
> (basically the same places as where I added the 'local_ip' argument).
>
> Then, I can post a patch to enable packaging a src-addr in that
> container as well. That should be a much smaller patch and so
> may seem less scary.

I gave this a try and it started looking very ugly.

I'll work on breaking my previously posted patch smaller
chunks.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

