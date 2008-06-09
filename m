From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/6] rpc: timeout patch
Date: Mon, 9 Jun 2008 17:39:12 -0400
Message-ID: <20080609213912.GC32446@fieldses.org>
References: <1213044696-32741-1-git-send-email-bfields@citi.umich.edu> <1213044696-32741-2-git-send-email-bfields@citi.umich.edu> <1213044696-32741-3-git-send-email-bfields@citi.umich.edu> <1213046330.19130.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Olga Kornievskaia <aglo@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33621 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777AbYFIVjN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Jun 2008 17:39:13 -0400
In-Reply-To: <1213046330.19130.12.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 09, 2008 at 05:18:50PM -0400, Trond Myklebust wrote:
> On Mon, 2008-06-09 at 16:51 -0400, J. Bruce Fields wrote:
> > From: Olga Kornievskaia <aglo@citi.umich.edu>
> > 
> > When a client gss upcall times out, we currently give a mesage reminding
> > the user to check whether gssd is running.
> > 
> > Currently gssd only listens on pipes under nfs/.  We expect to modify it
> > so it treats all clients the same regardless of protocol (as it probably
> > should have before), and new functionality may depend on that.  So
> > people may need to upgrade gssd to get such new functionality.
> > 
> > So it would be helpful if the error message specified which pipe exactly
> > the upcall was failing on, and suggested that the problem could be due
> > to an outdated gssd (not just a non-existant gssd).
> 
> NACK. I belive I've already made clear that I really don't like the idea
> of using d_path() in an error message.
> 
> Please just correct the existing error message to remind people that
> they need an up to date version of gssd, and add a comment in Kconfig
> stating exactly _which_ minimal version is needed.

Actually, after another look, maybe we should just do nothing:

The most likely next user of this is the nfsv4 callbacks.  But callbacks
aren't that crucial: if someone doesn't care about delegations, and
wants to delay upgrading gssd, they should be able to do that without
their server's logs getting spammed all the time.

So I'm inclined to just drop this--apologies.

--b.
