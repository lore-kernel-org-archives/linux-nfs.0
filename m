From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NLM: Revert parts of commit 24e36663
Date: Fri, 26 Sep 2008 14:51:40 -0400
Message-ID: <20080926185140.GB1492@fieldses.org>
References: <20080924184732.4078.83334.stgit@tarkus.1015granger.net> <20080925213831.GF14349@fieldses.org> <AED0D581-07B0-4EC6-90AB-2F61B6F3C76B@oracle.com> <20080926184554.GA1492@fieldses.org> <1222454975.10150.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45229 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227AbYIZSvm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 14:51:42 -0400
In-Reply-To: <1222454975.10150.8.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2008 at 02:49:35PM -0400, Trond Myklebust wrote:
> On Fri, 2008-09-26 at 14:45 -0400, J. Bruce Fields wrote:
> > > If so, we could post it after 
> > > the merge window closes.  It would give a little more time to do some 
> > > testing.
> > 
> > That sound suspiciously like "since this is a high priority, it will be
> > accepted later, so we can make it a lower priority."  Help!
> > 
> > But anyway, yes, we might have more time.
> 
> At the Kernel Summit Linus said he wants this kind of fix to go into the
> merge window rather than in the -rc series if possible. His position was
> that he'd rather revert a bad fix instead of delaying the testing in the
> mainline kernel...

Makes sense to me.

--b.
