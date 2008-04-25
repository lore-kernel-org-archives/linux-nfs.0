From: Bernd Schubert <bs-PKu+Ek1N2UGzQB+pC5nmwQ@public.gmane.org>
Subject: Re: multiple instances of rpc.statd
Date: Fri, 25 Apr 2008 16:30:36 +0200
Message-ID: <200804251630.36917.bs@q-leap.de>
References: <200804251531.21035.bs@q-leap.de> <4811E0D7.4070608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Cc: linux-nfs@vger.kernel.org
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.q-leap.de ([153.94.51.193]:45799 "EHLO mail.q-leap.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757017AbYDYOai (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2008 10:30:38 -0400
In-Reply-To: <4811E0D7.4070608@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Wendy.

On Friday 25 April 2008 15:47:03 Wendy Cheng wrote:
> Bernd Schubert wrote:
> > Hello,
> >
> > on servers with heartbeat managed resources one rather often has the
> > situation one exports different directories from different resources.
> >
> > It now may happen all resources are running on one host, but they can
> > also run from different hosts. The situation gets even more complicated
> > if the server is also a nfs client.
> >
> > In principle having different nfs resources works fine, only the statd
> > state directory is a problem. Or in principle the statd concept at all.
> > Actually we would need to have several instances of statd running using
> > different directories. These then would have to be migrated from one
> > server to the other on resource movement.
> > However, as far I understand it, there does not even exist the basic
> > concept for this, doesn't it?
>
> The efforts have been attempted (to remedy this issue) and a complete
> set of patches have been (kept) submitting for the past two years. The
> patch acceptance progress is very slow (I guess people just don't want
> to get bothered with cluster issues ?).

Well, I think people are just ignorant. I did see your discussions about NLM 
in the past on the NFS mailing list, but actually I didn't understand the 
entire point of discussion ;) I was simply used to active-passive services 
(mostly due to heartbeat-1.x) and there we just had /var/lib/nfs linked to 
the exported directory.

After I started to work here, I was confronted with the fact we do have 
working active-active clusters here, but nobody besides me ever cared about 
the locking problem :( NFS failovers just are done ignoring file locks.
Seems so far also nobody run into a problem, but maybe the result was so 
obscure that nobody ever bothered to complain...
I'm just afraid most admins will simply do like this...

>
> Anyway, the kernel side has the basic infrastructure to handle the
> problem (it stores the incoming clients IP address as part of its
> book-keeping record) - just a little bit tweak will do the job. However,
> the user side statd directory needs to get re-structured. I didn't
> publish the user side directory structure script during my last round of
> submission. Forking statd into multiple threads do not solve all the
> issues. Check out:
> https://www.redhat.com/archives/cluster-devel/2007-April/msg00028.html

Thanks, I will read this!


Thanks again,
Bernd

-- 
Bernd Schubert
Q-Leap Networks GmbH
