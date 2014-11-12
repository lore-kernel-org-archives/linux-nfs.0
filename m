Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48758 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752898AbaKLP6o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Nov 2014 10:58:44 -0500
Message-ID: <546383AB.6080105@RedHat.com>
Date: Wed, 12 Nov 2014 10:58:35 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: bstroesser@ts.fujitsu.com, linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [nfs-utils] [PATCH 0/3] rpc.mountd: fix some vulnerabilities
References: <d6437a$6ag11f@dgate10u.abg.fsc.net>	<5462545F.4010706@RedHat.com> <20141112100011.74b6549f@notabene.brown>
In-Reply-To: <20141112100011.74b6549f@notabene.brown>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/11/2014 06:00 PM, NeilBrown wrote:
>> Here is why they do not work: 
>> > 
>> > The fd that the write() is getting hung on, is not be created 
>> > by the 3 nfs_svc_create() calls in mountd:main(). Its
>> > being created by the accept() when the tcp connection
>> > is created (via SVC_RECV()), so making those fds coming 
>> > out of the nfs_svc_create() non-blocking does nothing. 
> Just to add to what Bodo replied:
> 
> SVC_RECV is a macro which calls .xp_recv, which in the TCP listen
> case is rendezvous_request.
> 
> rendezvous_request does the accept:
> 
>         if ((sock = accept(xprt->xp_fd, (struct sockaddr *)(void *)&addr,
>             &len)) < 0) {
> 
> and then
>         if (cd->maxrec != 0) {
>                 flags = fcntl(sock, F_GETFL, 0);
>                 if (flags  == -1)
>                         return (FALSE);
>                 if (fcntl(sock, F_SETFL, flags | O_NONBLOCK) == -1)
>                         return (FALSE);
>   
> so if cd->maxrec is not zero, O_NONBLOCK get set.
> 
> It gets set through an SVC_CONTROL -> xp_control -> svc_vc_rendezvous_control
> 
> call, which no-one ever makes, and it initialised to __svc_maxrec, which is
> set by the rpc_control() call that Bodo mentions.
> So providing rpc_control is called before the service is created, it should
> work fine.
> 
> I wonder why it didn't work for you...
Because I didn't apply the 3rd patch because it was marked
as experimental. I figured I would get the first two 
patches working and deal with it later... 

Plus although I did look at this code, I didn't notice the 
setting of the O_NONBLOCK on the fd from the accept.
Thanks for pointing it out.... 

steved.
