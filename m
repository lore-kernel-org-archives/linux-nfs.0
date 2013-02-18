Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44402 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754791Ab3BRVCV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Feb 2013 16:02:21 -0500
Date: Mon, 18 Feb 2013 16:02:18 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/14] lnfs: 3.8-rc7 release
Message-ID: <20130218210218.GB3391@fieldses.org>
References: <1361213276-17962-1-git-send-email-SteveD@redhat.com>
 <20130218195834.GA3391@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130218195834.GA3391@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 18, 2013 at 02:58:34PM -0500, bfields wrote:
> On Mon, Feb 18, 2013 at 01:47:42PM -0500, Steve Dickson wrote:
> > From: Steve Dickson <steved@redhat.com>
> > 
> > Here is the next release of the Label NFS patches, forward 
> > ported to linux-3.8-rc7
> > 
> > I believe I've  incorporated all code review that were made
> > from the last release,
> 
> Except I think this doesn't turn on minor version 2?
> 
> Also: did you figure out why NFSv4 wasn't working when the labeled NFS
> support is configured out?

Did a quick check, and that's still failing.

Both of those things need to be fixed before this can be merged.

And we still need an ACK from security people.

--b.
