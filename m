Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60458 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932551Ab3BSPSM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2013 10:18:12 -0500
Date: Tue, 19 Feb 2013 10:18:08 -0500
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
Message-ID: <20130219151808.GE3391@fieldses.org>
References: <1361213276-17962-1-git-send-email-SteveD@redhat.com>
 <20130218195834.GA3391@fieldses.org>
 <512395D7.5010205@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <512395D7.5010205@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 19, 2013 at 10:10:15AM -0500, Steve Dickson wrote:
> 
> 
> On 18/02/13 14:58, J. Bruce Fields wrote:
> > On Mon, Feb 18, 2013 at 01:47:42PM -0500, Steve Dickson wrote:
> >> > From: Steve Dickson <steved@redhat.com>
> >> > 
> >> > Here is the next release of the Label NFS patches, forward 
> >> > ported to linux-3.8-rc7
> >> > 
> >> > I believe I've  incorporated all code review that were made
> >> > from the last release,
> > Except I think this doesn't turn on minor version 2?
> Are you saying we need a -o v4.2 mount option to enable this feature?

Yes.  And the client needs to send requests with minor version 2, and
server needs to accept such requests.

> > Also: did you figure out why NFSv4 wasn't working when the labeled NFS
> > support is configured out?
> I'll look into this but this was not the case the last time I checked...

Let me know how I can help reproduce the problem.  All I did was:

	- build a kernel with CONFIG_NFS_V4_SECURITY_LABEL and
	  CONFIG_NFSD_V4_SECURITY_LABEL both off.
	- attempt a v4 mount between client and server both running that
	  kernel.

--b.
