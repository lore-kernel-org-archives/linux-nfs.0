Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34390 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759036Ab2HXPi0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Aug 2012 11:38:26 -0400
Date: Fri, 24 Aug 2012 11:38:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Subject: Re: [PATCH] svcrpc: sends on closed socket should stop immediately
Message-ID: <20120824153823.GA21184@fieldses.org>
References: <20120820215210.GJ5779@fieldses.org>
 <20120820223506.GB30155@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120820223506.GB30155@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 20, 2012 at 05:35:06PM -0500, Malahal Naineni wrote:
> J. Bruce Fields [bfields@fieldses.org] wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > svc_tcp_sendto sets XPT_CLOSE if we fail to transmit the entire reply.
> > However, the XPT_CLOSE won't be acted on immediately.  Meanwhile other
> > threads could send further replies before the socket is really shut
> > down.
...
> Instrumented svc_send_common() to send partial read replies, was able
> reproduce the corruption easily. After applying this patch, I wasn't
> able to reproduce the corruption. The patch looks good.

I wonder, maybe someone who understands the tcp code better could
answer: is it really possible for a sendto to fail and then a subsequent
send succeed?  If so, what are possible causes?

I'm curious how we'd reproduce this without the artificial fault
injection.

--b.
