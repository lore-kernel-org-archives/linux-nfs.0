Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60804 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658Ab1JTMcu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 08:32:50 -0400
Date: Thu, 20 Oct 2011 08:32:42 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [RFC PATCH 0/5] SUNRPC: "RPC pipefs per network namespace"
 preparations
Message-ID: <20111020123242.GN5444@fieldses.org>
References: <20111017120629.4541.67395.stgit@localhost6.localdomain6>
 <4EA000C6.1040502@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EA000C6.1040502@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2011 at 03:06:46PM +0400, Stanislav Kinsbursky wrote:
> Guys, please, spend some of your expensive time to review this patch-set briefly.

I'll try to take a look soon, but I'm travelling tomorrow through the
31st, and things will be a little hectic.

Just one quick comment:

> >The only problem about I'm not sure how to solve properly yet, is auth gss
> >pipes creations operations. Hoping for some help with it.

I suspect one reason it may be a little complicated is the
upcall-version switching.  The old version is deprecated, and there's no
need to support the combination of the old version with the a new
feature like containers.  And now that it's been there a while the
version-switching code already achieved its goal of avoiding a flag day.
So, one approach might be:

	- move all the code for the old gss upcall and for the version
	  switching under a new CONFIG_DEPRECATED_GSS, or similar.
	- print a warning if the old stuff is used, and plan to rip it
	  out completely in a future kernel version.
	- do something that works just in the !CONFIG_DEPRECATED_GSS
	  case.

Would that help?

--b.
