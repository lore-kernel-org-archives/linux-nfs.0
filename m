Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:52669 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752029Ab3EBF4f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 May 2013 01:56:35 -0400
Date: Thu, 2 May 2013 01:56:25 -0400
From: Jim Rees <rees@umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <steved@redhat.com>, Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Avoid DNS reverse resolution for server names (take 3)
Message-ID: <20130502055625.GA11376@umich.edu>
References: <1366380998-2581-1-git-send-email-steved@redhat.com>
 <20130502131332.5c0ce2b0@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130502131332.5c0ce2b0@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I really disliked the man page wording in the original patch. Yours is much
better.

Note that it's possible to have a fqdn with no dots in it, but I expect this
will never happen.
