From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 1/2] nfs(5): Replace the term "netid" in mount option descriptions
Date: Tue, 23 Sep 2008 15:55:31 -0400
Message-ID: <76bd70e30809231255hed38eebn5df0e884d5307426@mail.gmail.com>
References: <20080923161322.5119.20872.stgit@manray.1015granger.net>
	 <20080923161636.5119.54434.stgit@manray.1015granger.net>
	 <1222188968.7799.32.camel@localhost>
	 <76bd70e30809231011g5ed0cd11o6ccc06ab85f1a96c@mail.gmail.com>
	 <RTPCLUEXC1-PRDFRaqb000000d0@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.190]:23446 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbYIWTzd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2008 15:55:33 -0400
Received: by gv-out-0910.google.com with SMTP id e6so195808gvc.37
        for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2008 12:55:32 -0700 (PDT)
In-Reply-To: <RTPCLUEXC1-PRDFRaqb000000d0-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2008 at 3:04 PM, Talpey, Thomas
<Thomas.Talpey@netapp.com> wrote:
> At 01:11 PM 9/23/2008, Chuck Lever wrote:
>>kernel's rpcbind client when it is stuck using only portmap.  Plus,
>>the RDMA client-side transport plays fast and loose with the xprt's
>>prot field so it can get TCP for NLM traffic.  I tried pulling that
>>chain once before, and it's going to take some careful thought.
>
> I have no issue fixing that, if there's a better way. The only goal
> of the chain-pulling is to redirect the side protocols to UDP/TCP,
> much like the "mountproto=" option does. NLM, as you mention,
> is the tricky one, since it literally reaches into the NFS clnt struct
> and "borrows" the transport identifier by value.

Yup, that's the sticky part.

--
Chuck Lever
