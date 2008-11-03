From: Jim Rees <rees@umich.edu>
Subject: Re: stuck/hung nfsv4 mounts
Date: Mon, 3 Nov 2008 12:25:29 -0500
Message-ID: <20081103172529.GA9008@citi.umich.edu>
References: <1225724721.2247.29.camel@brian-laptop> <1225731544.6958.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.14.81]:49440 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbYKCRZi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2008 12:25:38 -0500
In-Reply-To: <1225731544.6958.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:

  BTW: NFSv4 + soft == BAD BAD BAD!

Maybe this combination should be prohibited.  Does it make any sense given
the stateful nature of v4?
