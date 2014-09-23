Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33557 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753982AbaIWCJb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 22:09:31 -0400
Date: Mon, 22 Sep 2014 22:09:28 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Simo Sorce <simo@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140923020928.GA1409@fieldses.org>
References: <1411413608-16462-1-git-send-email-steved@redhat.com>
 <1411413608-16462-2-git-send-email-steved@redhat.com>
 <20140922194057.GE26763@fieldses.org>
 <20140922154642.779189c8@willson.usersys.redhat.com>
 <54207E4A.7010300@RedHat.com>
 <20140922160050.0b85f044@willson.usersys.redhat.com>
 <20140923114229.0a9e294f@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140923114229.0a9e294f@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2014 at 11:42:29AM +1000, NeilBrown wrote:
> Surely gssproxy is only serving nfsd requests if both /run/gssproxy.pid
> exists and /proc/net/rpc/use-gss-proxy exists.
> If either of those files is missing, then rpc.svcgssd needs to run.
> In one case, the gssproxy daemon isn't available for some reason.  In the
> other case the kernel cannot make use of it.
> 
> Is that not correct?
> 
> That is exactly the rule that I (tried to) encode in the service file with
> these two conditions.

Eh, I see your point, but the gssproxy.pid one still seems a little odd
to me.

I guess it's friendlier to people that don't have gss-proxy installed at
all, or want to turn it off for some reason--but then they or their
distro can fix up the unit files too.

Otherwise if we've got gss-proxy and the kernel supports it then it
should work, and if it's failing to come up in that case I'd kind of
like to know why and get a bug report like "gssproxy failed to start" or
"krb5 exports stopped working" rather than "krb5 exports are working in
some subtly different way than they did last week."

--b.
