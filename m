Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38545 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754703Ab3BPWeP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Feb 2013 17:34:15 -0500
Date: Sat, 16 Feb 2013 17:34:07 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 14/15] NFSD: Server implementation of MAC Labeling
Message-ID: <20130216223407.GC28824@fieldses.org>
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com>
 <1360327163-20360-15-git-send-email-SteveD@redhat.com>
 <20130212225425.GM10267@fieldses.org>
 <511FEFCB.2090002@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <511FEFCB.2090002@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 16, 2013 at 03:44:59PM -0500, Steve Dickson wrote:
> On 12/02/13 17:54, J. Bruce Fields wrote:
> > 
> > Although: don't we need to check whether the exported filesystem
> > supports security labels?
> I took a quick look around and didn't see any interface to do that.
> Is it even possible to do this?

Try fetching a security label and check whether the response is
EOPNOTSUPP, I think.  That's what the ACL code does.

> >> +	/* XXX: should we have a MAY_SSECCTX? */
> > 
> > I don't know, should we?
> I vote no! ;-) What is that? 

Maybe this is a question for Dave--who wrote that comment?  How should
we be checking for permissions to set the security label?

--b.
