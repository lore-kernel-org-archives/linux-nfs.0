Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:51350 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259Ab1K3Xri (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Nov 2011 18:47:38 -0500
Message-ID: <4ED6C095.9070701@candelatech.com>
Date: Wed, 30 Nov 2011 15:47:33 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] svcrpc: avoid memory-corruption on pool shutdown
References: <20111130233925.GA354@fieldses.org> <20111130234009.GB354@fieldses.org> <20111130234303.GC354@fieldses.org>
In-Reply-To: <20111130234303.GC354@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/30/2011 03:43 PM, J. Bruce Fields wrote:
> Anyone see any remaining hole, or does this finally fix the problem?
>
> Any idea for something simpler?
>
> If not I'll likely commit this for 3.2 and -stable before the end of the
> week.

I never did understand this code too well, so I'm afraid I can't
really review this.  I'll be sure to run our NFS stress tests when we upgrade
to newer kernels..but that will likely be a while.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

