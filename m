From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [RFC] After nfs restart, locks can't be recovered which record
 by lockd before
Date: Fri, 15 Jan 2010 17:28:14 +0800
Message-ID: <4B50352E.7040606@cn.fujitsu.com>
References: <4B4D979D.6090307@cn.fujitsu.com>	<20100113075155.5c409567@barsoom.rdu.redhat.com>	<4B4EE6B9.8090104@cn.fujitsu.com> <20100114071036.09583f4a@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62830 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757051Ab0AOJ2S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Jan 2010 04:28:18 -0500
In-Reply-To: <20100114071036.09583f4a-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

Jeff Layton :
> On Thu, 14 Jan 2010 17:41:13 +0800
> Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:
> 
>>> IOW, "you're doing it wrong". If you want locks to be reclaimed then
>>> you probably need to restart the nfslock service too.
>>>
>>   Don't you think it's more reasonable that locks should be recovered 
>>   when nfs restart cause lockd restart?
>>
> 
> Sure, that's the idea. That said, I'm leery of trying to make this too
> automatic. Extra complexity in this sort of thing often means that we
> get emergent behaviors from the system that we don't expect. I'm not
> sure that risk is worth it to guard against admins restarting lockd
> like this without forcing notifications to be sent.
> 

  IMO, when lockd restart without statd restart, lockd should recovered those locks.
  If the NFSv3's designers think it's not needed when the design it, we would respect
  theirs idea at first. But, I think this is indeed a problem!

-- 
Regards
Mi Jinlong

