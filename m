From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 0/8] rpcbind v4 support in net/sunrpc/svc*
Date: Wed, 23 Jul 2008 19:05:31 -0400
Message-ID: <1216854331.9296.92.camel@localhost>
References: <20080630224147.24887.18730.stgit@ellison.1015granger.net>
	 <20080719010738.GA19106@fieldses.org> <20080720211744.GA32178@fieldses.org>
	 <76bd70e30807211207q4fc509e0h4a1a560fe8097de7@mail.gmail.com>
	 <20080723215336.GC29065@fieldses.org>
	 <76bd70e30807231547j19e9fd8dv7a14c2795226dcd6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2215 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752201AbYGWXG1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jul 2008 19:06:27 -0400
In-Reply-To: <76bd70e30807231547j19e9fd8dv7a14c2795226dcd6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-07-23 at 18:47 -0400, Chuck Lever wrote:
> Well, Sankar just informed me that the lock recovery bug we discussed
> last week was most likely another problem not related to my IPv6
> changes.  Bug found on RHEL 5, and fixed there, needs to go
> upstream... he may have a patch I can apply to my repo so we can
> confirm that NFSv2/v3 lock recovery is not affected by my IPv6-related
> changes.

Yes. I just talked to Sankar about this: apparently he was hitting the
bug that lockd no longer listens on UDP sockets if you are using
NFS-over-TCP. Unfortunately, some servers send statd reboot
notifications on UDP only, and so his client was no longer attempting to
recover locks...


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
