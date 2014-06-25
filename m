Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f175.google.com ([74.125.82.175]:47585 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754513AbaFYNdF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 09:33:05 -0400
Message-ID: <53AACF88.5000006@suse.cz>
Date: Wed, 25 Jun 2014 15:32:56 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
To: Jeff Layton <jlayton@primarydata.com>, stable@vger.kernel.org
CC: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [stable PATCH] nfsd: don't try to reuse an expired DRC entry
 off the list
References: <1403290612-15341-1-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403290612-15341-1-git-send-email-jlayton@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/20/2014 08:56 PM, Jeff Layton wrote:
> From: Jeff Layton <jlayton@redhat.com>
> 
> This is commit a0ef5e19684f0447da9ff0654a12019c484f57ca in mainline.
> 
> While the commit message below doesn't lay this out, we've subsequently
> found that there are some cases where an entry that's still in use can
> be freed prematurely if a particular operation takes a *very* long time
> (on the order of minutes) and/or the server is very busy and doesn't
> have a lot of memory dedicated to the DRC. This patch eliminates that
> possibility, so it's actually more than just a cleanup.
> 
> The regression crept in in v3.9, and this patch went into mainline in
> v3.14. Please apply this to any stable kernel between those two
> mainline releases.

Now applied to 3.12. Thanks.


-- 
js
suse labs
