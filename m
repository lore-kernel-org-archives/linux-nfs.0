From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount: Set protocol family properly for "udp" and "tcp"
Date: Thu, 18 Feb 2010 06:45:01 -0500
Message-ID: <4B7D283D.9000905@RedHat.com>
References: <20100216221010.2977.6043.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62609 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752374Ab0BRLpG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Feb 2010 06:45:06 -0500
In-Reply-To: <20100216221010.2977.6043.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/16/2010 05:10 PM, Chuck Lever wrote:
> In nfs_nfs_proto_family(), *family is never set if the legacy
> "udp" or "tcp" mount options are specified.  The result is an error
> message at umount time, for example:
> 
> umount.nfs: DNS resolution failed for
>   2001:5c0:1101:2f00:250:8dff:fe95:5c61: ai_family not supported
> 
> even if mount was built with IPv6 support.
> 
> The man page says that "udp" is a synonym for "proto=udp", and
> likewise for "tcp".  Thus, we don't look at config_default_family
> here, but always use AF_INET explicitly, to be consistent with the
> meaning of proto=.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Reviewed-by: Jeff Layton <jlayton@redhat.com>
> ---
Committed...

steved.
