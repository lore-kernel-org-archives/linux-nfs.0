From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/2] sunrpc: add sv_maxconn field to svc_serv (try #3)
Date: Mon, 20 Oct 2008 18:55:43 -0400
Message-ID: <20081020185543.17ffb29a@tleilax.poochiereds.net>
References: <1224517918-7788-1-git-send-email-jlayton@redhat.com>
	<20081020225158.GK27702@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57086 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751787AbYJTWzs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2008 18:55:48 -0400
In-Reply-To: <20081020225158.GK27702@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 20 Oct 2008 18:51:58 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> My one small worry is that we'll find a better fix for all this at some
> point, and then the sysctl will be a useless dangling appendage.  But,
> OK--both applied.
> 

Thanks, Bruce. If we can think of a better way to do this, I'm all for
it. Hopefully it won't be too difficult a thing to change if that
happens.
-- 
Jeff Layton <jlayton@redhat.com>
