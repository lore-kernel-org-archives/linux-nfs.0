From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] OpenSRS blog post alludes to a Linux NFS bug in 2.6.19
Date: Sun, 19 Oct 2008 12:45:01 -0400
Message-ID: <1224434701.9433.3.camel@localhost>
References: <20081019032811.GA30801@outblaze.com>
	 <20081019064405.0db1e004@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yusuf Goolamabbas <yusufg-lA0CmJ9G6+FWk0Htik3J/w@public.gmane.org>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:49724 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491AbYJSQpM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 19 Oct 2008 12:45:12 -0400
In-Reply-To: <20081019064405.0db1e004-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2008-10-19 at 06:44 -0400, Jeff Layton wrote:
> On Sun, 19 Oct 2008 11:28:11 +0800
> Yusuf Goolamabbas <yusufg-lA0CmJ9G6+FWk0Htik3J/w@public.gmane.org> wrote:
> 
> > Anybody know if this is bug is fixed and if so in which kernel revision.
> > Any ideas about its impact on vendor kernels (RHEL/SUSE Enterprise)
> > 
> > http://opensrs.com/blog/2008/10/technical-debrief-on-october-cluster-a-email-service-issue/
> > 
> 
> I know that more recent RHEL kernels have this fixed. The bug to track it was here:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=369561
> 
> It's also easy to tell if you have a kernel with this problem. Just do
> a single TCP mount on the client, and then run:
> 
> $ rpcinfo -p
> 
> ...you should see port registrations for nlockmgr. If you don't see any
> UDP ones, then the kernel has the problem.
> 

Note that the workaround was simply to add 

     lockd.nlm_udpport=<unused portnumber>

to your kernel bootparameters.

Cheers
  Trond

