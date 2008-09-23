From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 1/2] nfs(5): Replace the term "netid" in mount
  option descriptions
Date: Tue, 23 Sep 2008 15:04:55 -0400
Message-ID: <RTPCLUEXC1-PRDFRaqb000000d0@RTPMVEXC1-PRD.hq.netapp.com>
References: <20080923161322.5119.20872.stgit@manray.1015granger.net>
 <20080923161636.5119.54434.stgit@manray.1015granger.net>
 <1222188968.7799.32.camel@localhost>
 <76bd70e30809231011g5ed0cd11o6ccc06ab85f1a96c@mail.gmail.com> <76bd70e30809231011g5ed0cd11o6ccc06ab85f1a96c@mail.gmail.co
 m>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19975 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751468AbYIWTFi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Sep 2008 15:05:38 -0400
In-Reply-To: <76bd70e30809231011g5ed0cd11o6ccc06ab85f1a96c-JsoAwUIsXouhRSP0FMvGiw@public.gmane.org
 m>
References: <20080923161322.5119.20872.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
 <20080923161636.5119.54434.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
 <1222188968.7799.32.camel@localhost>
 <76bd70e30809231011g5ed0cd11o6ccc06ab85f1a96c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 01:11 PM 9/23/2008, Chuck Lever wrote:
>kernel's rpcbind client when it is stuck using only portmap.  Plus,
>the RDMA client-side transport plays fast and loose with the xprt's
>prot field so it can get TCP for NLM traffic.  I tried pulling that
>chain once before, and it's going to take some careful thought.

I have no issue fixing that, if there's a better way. The only goal
of the chain-pulling is to redirect the side protocols to UDP/TCP,
much like the "mountproto=" option does. NLM, as you mention,
is the tricky one, since it literally reaches into the NFS clnt struct
and "borrows" the transport identifier by value.

Tom.

