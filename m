From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [RFC] new client gssd upcall
Date: Thu, 19 Jun 2008 14:13:19 -0400
Message-ID: <1213899199.7120.22.camel@localhost>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
	 <20080616102859.66fa6a34@tleilax.poochiereds.net>
	 <20080617213622.GA5849@fieldses.org> <1213739969.7288.90.camel@localhost>
	 <485A7D2D.4060206@citi.umich.edu>
	 <20080619114929.5c211ec9@tleilax.poochiereds.net>
	 <1213895182.7120.13.camel@localhost>
	 <20080619132720.6bce2bb9@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Olga Kornievskaia <aglo@citi.umich.edu>,
	"J. Bruce Fields" <bfields@fieldses.org>, kwc@citi.umich.edu,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1324 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751469AbYFSSNj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jun 2008 14:13:39 -0400
In-Reply-To: <20080619132720.6bce2bb9-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-06-19 at 13:27 -0400, Jeff Layton wrote:
> There's also no reason we couldn't use keys for
> idmap upcalls as well. I'm considering them for a similar idmap scheme
> for CIFS.

Ewww.... NACK, NACK, NACK, NACK....

There is a perfectly good reason why you wouldn't ever want to use keys
for idmap upcalls: keys are user/process/thread objects while idmapd
entries are NFSv4-namespace objects.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
