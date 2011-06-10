From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH v2 0/6]  nfs-utils:  Support binding to source address.
Date: Fri, 10 Jun 2011 13:50:41 -0700
Message-ID: <4DF283A1.3070502@candelatech.com>
References: <1307734898-12860-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: greearb@candelatech.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47436 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757477Ab1FJUuq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 16:50:46 -0400
In-Reply-To: <1307734898-12860-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/10/2011 12:41 PM, greearb@candelatech.com wrote:
> From: Ben Greear<greearb@candelatech.com>
>
> This lets one specify the source IP address for
> sockets, allowing users to leverage routing rules
> on multi-homed systems.
>
> Kernel patches to RPC and NFS are needed to complete
> full functionality.
>
> v4:  Remove get_socket() modifications: stropt mount doesn't use them.
>         (This removed old patch 4, and modified patch 1)
>       Remove open-parsing of srcaddr= in mount logic.  Move parsing
>         to nfs_validate_options()

Gah, ipv6 wasn't enabled, so I introduced a few bugs.  Will
post v3 series with fixes shortly.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

