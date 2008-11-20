From: Max Kellermann <max-hDT0AjmEH7RAfugRpC6u6w@public.gmane.org>
Subject: Re: High load in 2.6.27, NFS / rpcauth_lookup_credcache()?
Date: Thu, 20 Nov 2008 15:08:30 +0100
Message-ID: <20081120140830.GA23697@squirrel.roonstrasse.net>
References: <20081022091207.GA12996@squirrel.roonstrasse.net> <20081023123628.GA18549@squirrel.roonstrasse.net> <1224773745.7625.4.camel@localhost> <20081024083913.GA15197@squirrel.roonstrasse.net> <1224871763.22672.33.camel@localhost> <20081027095843.GA10937@squirrel.roonstrasse.net> <1225122503.14242.12.camel@heimdal.trondhjem.org> <20081117123536.GA16539@squirrel.roonstrasse.net> <1227133861.28898.26.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp3.netcologne.de ([194.8.194.66]:35829 "EHLO
	smtp3.netcologne.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754794AbYKTOIc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Nov 2008 09:08:32 -0500
In-Reply-To: <1227133861.28898.26.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2008/11/19 23:31, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> Looking at the above, it seems that you're spending an inordinate amount
> of time in generic_match too.
> Could you see if the following patch helps?

That fixes the problem.  The first kernel symbol in oprofile is the
tg3 network driver at 2%.

Max
