From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC] After nfs restart, locks can't be recovered which record
 by lockd before
Date: Thu, 14 Jan 2010 07:10:36 -0500
Message-ID: <20100114071036.09583f4a@tlielax.poochiereds.net>
References: <4B4D979D.6090307@cn.fujitsu.com>
	<20100113075155.5c409567@barsoom.rdu.redhat.com>
	<4B4EE6B9.8090104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43740 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751402Ab0ANMLC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jan 2010 07:11:02 -0500
In-Reply-To: <4B4EE6B9.8090104@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 14 Jan 2010 17:41:13 +0800
Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:

> > IOW, "you're doing it wrong". If you want locks to be reclaimed then
> > you probably need to restart the nfslock service too.
> > 
> 
>   Don't you think it's more reasonable that locks should be recovered 
>   when nfs restart cause lockd restart?
> 

Sure, that's the idea. That said, I'm leery of trying to make this too
automatic. Extra complexity in this sort of thing often means that we
get emergent behaviors from the system that we don't expect. I'm not
sure that risk is worth it to guard against admins restarting lockd
like this without forcing notifications to be sent.

-- 
Jeff Layton <jlayton@redhat.com>
