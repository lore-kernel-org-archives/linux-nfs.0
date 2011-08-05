Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18089 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754411Ab1HECOY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2011 22:14:24 -0400
Content-Type: text/plain; charset=us-ascii
Message-ID: <20027.20987.752925.471500@regina.usersys.redhat.com>
Date: Fri, 5 Aug 2011 12:14:19 +1000
From: Max Matveev <makc@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH] Update nfs(5) manpage - timeo for NFS/TCP
In-Reply-To: <20110805013936.GB15643@merit.edu>
References: <20026.13331.411712.805796@regina.usersys.redhat.com>
	<20110804062858.EAD96813270B@regina.usersys.redhat.com>
	<20110804120401.GB9984@merit.edu>
	<20027.16401.281058.897798@regina.usersys.redhat.com>
	<20110805013936.GB15643@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 4 Aug 2011 21:39:36 -0400, Jim Rees wrote:

 rees> Max Matveev wrote:
 rees>   	The NFS client performs linear backoff: after each
 rees>   	retransmission the timeout is increased by timeo up to the
 rees>   	maximum of 600 seconds.

 rees> Good point about keeping this together.  Probably should be a
 rees> semicolon, but if you go with a colon, capitalize "after".

Will keep the colon and capitalize.

max

