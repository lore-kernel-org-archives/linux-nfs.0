From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: linux-nfs.org will be going down for an upgrade today...
Date: Mon, 17 May 2010 15:15:25 -0400
Message-ID: <1274123725.4354.6.camel@heimdal.trondhjem.org>
References: <1273511220.5740.12.camel@localhost.localdomain>
	 <1273605127.2810.12.camel@localhost.localdomain>
	 <4BF17A87.1040406@oracle.com>
	 <1274117929.4354.3.camel@heimdal.trondhjem.org>
	 <4BF18172.4040607@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Dr. J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, pnfs@linux-nfs.org,
	labeled-nfs@linux-nfs.org, keyrings@linux-nfs.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:43116 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755878Ab0EQTPd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 May 2010 15:15:33 -0400
In-Reply-To: <4BF18172.4040607@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-05-17 at 13:48 -0400, Chuck Lever wrote: 
> On 05/17/10 01:38 PM, Trond Myklebust wrote:
> > On Mon, 2010-05-17 at 13:19 -0400, Chuck Lever wrote:
> >> On 05/11/2010 03:12 PM, Trond Myklebust wrote:
> >>> On Mon, 2010-05-10 at 13:07 -0400, Trond Myklebust wrote:
> >>>> Hi,
> >>>>
> >>>> I'm planning on upgrading the Linux distribution on linux-nfs.org to a
> >>>> newer release today. Unfortunately, this has to be done during working
> >>>> hours since I no longer have physical access to the CITI machine room
> >>>> (and so have to rely on Bruce being available should the remote access
> >>>> fail).
> >>>>
> >>>> I expect to start at around 2pm EST (in 1 hour from now). Hopefully the
> >>>> down time will be less than an hour or two.
> >>>> During that time, expect no access to www.linux-nfs.org, the git daemon,
> >>>> wiki.linux-nfs.org, bugzilla.linux-nfs.org or the linux-nfs.org mailing
> >>>> lists.
> >>>>
> >>>> I'll send a mail once everything is up and running again...
> >>>
> >>> As feared it took a good deal more time than expected, however I believe
> >>> that everything should be up and working again now.
> >>
> >> I've found two anomalies so far (and they may be on my end, fwiw).
> >>
> >> 1.  Yesterday, I tried to update the IPv6 working document on the NFSv4
> >> wiki, and the edit failed with a page that said an "internal error"
> >> occurred.
> >
> > Not sure about this. Is it reproducible?
> 
> Yes.  I just tried it again.
> 
> The error page says you can set $wgShowExceptionDetails = true; at the 
> bottom of LocalSettings.php to show detailed debugging information.

OK. I think I've fixed it: we were hitting a bug in the SpamBlackList
module. I've disabled that module for the time being...

