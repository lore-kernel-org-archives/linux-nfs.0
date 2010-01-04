From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount.nfs: don't use IPv6 unless IPV6_SUPPORTED is set
Date: Mon, 04 Jan 2010 15:44:35 -0500
Message-ID: <4B425333.6060707@RedHat.com>
References: <1262634454-2330-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146Ab0ADUol (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Jan 2010 15:44:41 -0500
In-Reply-To: <1262634454-2330-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/04/2010 02:47 PM, Jeff Layton wrote:
> Commit 1f3fae1fb25168aac187ff1881738c8ad53a8763 made mount.nfs start
> looking up and trying to use IPv6 addresses when mount.nfs was built
> against libtirpc (even when --enable-ipv6 wasn't specified).
> 
> The problem seems to be that nfs_nfs_proto_family() is basing the family
> on HAVE_LIBTIRPC. I think it should be basing it on IPV6_SUPPORTED
> instead.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> Acked-by: Chuck Lever <chuck.lever@oracle.com>
Committed...

steved.
