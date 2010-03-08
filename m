From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mountd: fix --manage-gids hang due to int/uint bug
Date: Mon, 08 Mar 2010 11:23:56 -0500
Message-ID: <4B95249C.9020306@RedHat.com>
References: <20100302204930.GA8609@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753265Ab0CHQX6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Mar 2010 11:23:58 -0500
In-Reply-To: <20100302204930.GA8609@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/02/2010 03:49 PM, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> A uid or gid should be represented as unsigned, not signed.
> 
> The conversion to signed here could cause a hang on access by an unknown
> user to a server running mountd with --manage-gids; such a user is
> likely to be mapped to 232-1, which may be converted to 231-1 when
> represented as an int, resulting in a downcall for uid 231-1, hence the
> original rpc hanging forever waiting for a cache downcall for 232-1.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Committed... 

steved.

