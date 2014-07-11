Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39598 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753003AbaGKWLX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2014 18:11:23 -0400
Date: Fri, 11 Jul 2014 18:11:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 2/4] NFSD: Rervert "knfsd: locks: flag NFSv4-owned locks"
Message-ID: <20140711221121.GC13656@fieldses.org>
References: <53BAAAC5.9000106@gmail.com>
 <20140707132633.5eb59753@tlielax.poochiereds.net>
 <53BB6445.3060508@gmail.com>
 <20140708070320.1d5646f0@tlielax.poochiereds.net>
 <53BBE35B.6090003@gmail.com>
 <20140708083956.0799b87c@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140708083956.0799b87c@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 08, 2014 at 08:39:56AM -0400, Jeff Layton wrote:
> <facepalm>
> Ahh ok, I see what you're saying now. I'll leave it to you to respin
> once the rest of the client_mutex removal series is merged.
> </facepalm>

Apologies, ignored this thread, but I'm dropping this patch for now
based on that comment.

--b.
