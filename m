From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount.nfs: set the default family for lookups based on
 Defaultproto= setting (try #2)
Date: Fri, 12 Feb 2010 14:25:24 -0500
Message-ID: <4B75AB24.2070609@RedHat.com>
References: <1265399169-19445-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14808 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754777Ab0BLTZf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Feb 2010 14:25:35 -0500
In-Reply-To: <1265399169-19445-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/05/2010 02:46 PM, Jeff Layton wrote:
> This is the second iteration of this patch. The only difference here
> is that this one has default_value call nfs_nfs_proto_family regardless
> of whether IPV6_SUPPORTED is set.
> 
> When IPv6 is enabled, the Proto= config file option is treated as a
> netid, and the address family for lookups is selected based on that
> setting. The Defaultproto= option however still only affects the
> protocol setting for the sockets (IPPROTO_*) and not the address family.
> 
> This patch makes it so that if someone sets the "Defaultproto=" option
> in the nfsmount.conf, it's used to determine the default address family
> for lookups as well as the protocol type.
> 
> This gives users a way to force a particular address family to be used
> universally for mounts and brings the behavior of the Defaultproto=
> option in line with the Proto= option.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>
Committed...

steved.
