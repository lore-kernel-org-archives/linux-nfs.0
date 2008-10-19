From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [NFS] OpenSRS blog post alludes to a Linux NFS bug in 2.6.19
Date: Sun, 19 Oct 2008 06:44:05 -0400
Message-ID: <20081019064405.0db1e004@tleilax.poochiereds.net>
References: <20081019032811.GA30801@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Yusuf Goolamabbas <yusufg-lA0CmJ9G6+FWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47870 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168AbYJSKoL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 19 Oct 2008 06:44:11 -0400
In-Reply-To: <20081019032811.GA30801-lA0CmJ9G6+FWk0Htik3J/w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 19 Oct 2008 11:28:11 +0800
Yusuf Goolamabbas <yusufg-lA0CmJ9G6+FWk0Htik3J/w@public.gmane.org> wrote:

> Anybody know if this is bug is fixed and if so in which kernel revision.
> Any ideas about its impact on vendor kernels (RHEL/SUSE Enterprise)
> 
> http://opensrs.com/blog/2008/10/technical-debrief-on-october-cluster-a-email-service-issue/
> 

I know that more recent RHEL kernels have this fixed. The bug to track it was here:

https://bugzilla.redhat.com/show_bug.cgi?id=369561

It's also easy to tell if you have a kernel with this problem. Just do
a single TCP mount on the client, and then run:

$ rpcinfo -p

...you should see port registrations for nlockmgr. If you don't see any
UDP ones, then the kernel has the problem.

-- 
Jeff Layton <jlayton@redhat.com>
