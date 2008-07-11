From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH V2] make "noac" and "actimeo=0" work correctly
Date: Fri, 11 Jul 2008 16:19:00 -0400
Message-ID: <1215807540.17983.2.camel@localhost>
References: <484EE994.5030907@redhat.com> <487390EC.7080403@redhat.com>
	 <76bd70e30807100858g58fbf454uc9331035a2bbf264@mail.gmail.com>
	 <487649AE.1090909@redhat.com> <1215718184.7126.44.camel@localhost>
	 <4877BF39.20102@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: chucklever@gmail.com, NFS list <linux-nfs@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57578 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133AbYGKUTt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2008 16:19:49 -0400
In-Reply-To: <4877BF39.20102@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-07-11 at 16:14 -0400, Peter Staubach wrote:
> Given that we seem to "own" time_in_range(), how about the
> attached patch which just modifies time_in_range() to calculate
> [b,c) instead of [b,c], removes the special case for attrtimeo==0
> in nfs_attribute_timeout() and adds a comment that Chuck requested
> concerning the need to ensure that zero timeout values continue
> to work?

I'm fine with that, but still suggest that you change the name in order
to avoid confusing possible out-of-tree users.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
