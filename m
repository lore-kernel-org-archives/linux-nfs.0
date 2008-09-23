From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/2] nfs(5): Replace the term "netid" in mount option descriptions
Date: Tue, 23 Sep 2008 13:11:13 -0400
Message-ID: <76bd70e30809231011g5ed0cd11o6ccc06ab85f1a96c@mail.gmail.com>
References: <20080923161322.5119.20872.stgit@manray.1015granger.net>
	 <20080923161636.5119.54434.stgit@manray.1015granger.net>
	 <1222188968.7799.32.camel@localhost>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.188]:11593 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbYIWRL1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2008 13:11:27 -0400
Received: by gv-out-0910.google.com with SMTP id e6so165707gvc.37
        for <linux-nfs@vger.kernel.org>; Tue, 23 Sep 2008 10:11:13 -0700 (PDT)
In-Reply-To: <1222188968.7799.32.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2008 at 12:56 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Tue, 2008-09-23 at 12:16 -0400, Chuck Lever wrote:
>> Mike Eisler noted that the use of the term "netid" in the descriptions
>> of the "proto=" option is not appropriate, since Linux does not allow
>> "udp6" or "tcp6".
>
> Why is it too late to add udp6/tcp6?

It's not.  We could certainly introduce this as part of IPv6 support.
But I'm not sure we want to add it.  No-one has asked for it, except
for Mike.  I don't find it especially practical to have to change
"udp" to "udp6" on clients if the server is changed from IPv4 to IPv6
addressing.

But it *is* too late for 2.6.28 at this point.  We would need to
retrofit the NFS mount option parser, and do something clever for the
kernel's rpcbind client when it is stuck using only portmap.  Plus,
the RDMA client-side transport plays fast and loose with the xprt's
prot field so it can get TCP for NLM traffic.  I tried pulling that
chain once before, and it's going to take some careful thought.

Then all of this would need lots of testing.

So we wouldn't see this feature until next March at the earliest.
Right now, the documentation doesn't reflect the behavior of the
*existing* code base, which treats these as transports, not netids.

-- 
Chuck Lever
