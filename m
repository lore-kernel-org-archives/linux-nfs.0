From: "NeilBrown" <neilb@suse.de>
Subject: Re: RESTRICTED_STATD
Date: Sat, 30 Aug 2008 07:31:58 +1000 (EST)
Message-ID: <3400963b9465552abb83ecefede125bc.squirrel@neil.brown.name>
References: <6972A199-D332-4E74-9D47-70EC2CA381FE@oracle.com>
    <48B5332B.2040800@RedHat.com>
    <76bd70e30808270714p4342c8c3k8d1b98763cc95aef@mail.gmail.com>
    <EB4BA6CC-B023-49DC-9FE6-BD478DA5CB9F@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Steve Dickson" <steved@redhat.com>,
	"Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
To: "Chuck Lever" <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:42373 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751207AbYH2VcF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Aug 2008 17:32:05 -0400
In-Reply-To: <EB4BA6CC-B023-49DC-9FE6-BD478DA5CB9F@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, August 30, 2008 6:56 am, Chuck Lever wrote:
> A little follow-up here.
>
> Steve and I looked at the nfs-utils-1.1.3 RPM for Fedora today.  I did
> an "rpmbuild -bc" and looked at it's config.h, and RESTRICTED_STATD is
> defined as 1.  So it uses the default.
>
> Looking at the code, it appears that when RESTRICTED_STATD is set,
> NL_ADDR() is always going to be the loopback address.  Neil, is that
> your understanding of this code?
>
Nearly.
If RESTRICTED_STATD is defined (to anything), MON, UNMON, UNMON_ALL
and SIMU_CRASH are only honour if they come from 127.0.0.1, so the
callback address (NL_ADDR) for any service that statd is monitoring
will always be local.
Only NOTIFY can come from other hosts (to tell us they rebooted).

Also, only the lockd callback service is recognised.  If any service
other than lockd registers a callback it will be ignored, even if it
is from localhost.

This last point is the only bit that could conceivably cause a problem.

However we don't really want any user to be able to request a callback
to any random service....
I wonder if anyone uses for statd for anything but lockd, and how
could we know?

NeilBrown

