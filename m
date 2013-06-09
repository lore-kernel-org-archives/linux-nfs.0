Return-Path: linux-nfs-owner@vger.kernel.org
Received: from s22.webhostingserver.nl ([195.211.72.238]:63556 "EHLO
	s22.webhostingserver.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752188Ab3FIIAB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Jun 2013 04:00:01 -0400
Received: from localhost ([::1] helo=vdtoorn.nl)
	by s22.webhostingserver.nl with esmtpa (Exim 4.80.1)
	(envelope-from <richard@vdtoorn.nl>)
	id 1UlaXZ-0001FK-UM
	for linux-nfs@vger.kernel.org; Sun, 09 Jun 2013 09:59:54 +0200
Message-ID: <18bf175abb39f6b946156dc44fc9d111.squirrel@vdtoorn.nl>
In-Reply-To: <3e068504c6a4b683359bad7610d84bc5.squirrel@vdtoorn.nl>
References: <3e068504c6a4b683359bad7610d84bc5.squirrel@vdtoorn.nl>
Date: Sun, 9 Jun 2013 09:59:53 +0200
Subject: Re: Kerberized NFS failure with 3.9.0-rc1 (and later)
From: richard@vdtoorn.nl
To: linux-nfs@vger.kernel.org
Reply-To: richard@vdtoorn.nl
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replying to myself, this looks to be the same problem as was reported by
Sven earlier this week:

http://www.spinics.net/lists/linux-nfs/msg37454.html

Happy to assist in debugging and getting this resolved.

Richard

> Some details:
>
> Client: debian unstable "Sid", kernel 3.9.0 (nfs-common=1.2.8-4)
> Server: debian 7.0 "Wheezy", nfs-common=1.2.6-3
>
> When upgrading the server to 3.9.0-rc1, it's giving access denied
> When upgrading the server to 3.9.0 or 3.9.5, it's locking
>
> There is no error on the server, but the logfile on the client mentions
> the following:
>
> rpc.gssd[1930]: ERROR: GSS-API: error in gss_free_lucid_sec_context():
> GSS_S_NO_CONTEXT (No context has been established) - Unknown error
> Jun  8 21:22:42 dell rpc.gssd[1930]: WARN: failed to free lucid sec
> context


