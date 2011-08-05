Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17496 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756126Ab1HEA57 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2011 20:57:59 -0400
Content-Type: text/plain; charset=us-ascii
Message-ID: <20027.16401.281058.897798@regina.usersys.redhat.com>
Date: Fri, 5 Aug 2011 10:57:53 +1000
From: Max Matveev <makc@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH] Update nfs(5) manpage - timeo for NFS/TCP
In-Reply-To: <20110804120401.GB9984@merit.edu>
References: <20026.13331.411712.805796@regina.usersys.redhat.com>
	<20110804062858.EAD96813270B@regina.usersys.redhat.com>
	<20110804120401.GB9984@merit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 4 Aug 2011 08:04:01 -0400, Jim Rees wrote:

 rees> I'm not crazy about the wording.  How about

 rees>   For NFS over TCP the default timeo is 600 (60 seconds).  The NFS client
 rees>   performs linear backoff.  After each retransmission the timeout is
 rees>   increased by timeo up to the maximum of 600 seconds.

I'm fine with this except the third sentence is the explanation of
"linear backoff" - I'd rather keep them together, i.e.:

	The NFS client performs linear backoff: after each
	retransmission the timeout is increased by timeo up to the
	maximum of 600 seconds.

 rees> Finally, I would call them "deciseconds".

Secquipedalians'r'us.

 rees> timeo: The time in deciseconds (tenths of a second) ...
Will do.

Anything else before I send v2?

max
