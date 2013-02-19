Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51135 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757174Ab3BSUYr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2013 15:24:47 -0500
Date: Tue, 19 Feb 2013 15:24:43 -0500
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
Message-ID: <20130219202443.GA14606@fieldses.org>
References: <1361213276-17962-1-git-send-email-SteveD@redhat.com>
 <20130218195834.GA3391@fieldses.org>
 <512395D7.5010205@RedHat.com>
 <20130219151808.GE3391@fieldses.org>
 <51239CFF.9000600@RedHat.com>
 <5123DE7F.7050803@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5123DE7F.7050803@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 19, 2013 at 03:20:15PM -0500, Steve Dickson wrote:
> On 19/02/13 10:40, Steve Dickson wrote:
> >>>> >>> Also: did you figure out why NFSv4 wasn't working when the labeled NFS
> >>>> >>> support is configured out?
> >>> >> I'll look into this but this was not the case the last time I checked...
> >> > 
> >> > Let me know how I can help reproduce the problem.  All I did was:
> >> > 
> >> > 	- build a kernel with CONFIG_NFS_V4_SECURITY_LABEL and
> >> > 	  CONFIG_NFSD_V4_SECURITY_LABEL both off.
> >> > 	- attempt a v4 mount between client and server both running that
> >> > 	  kernel.
> The bug is due to the fact the the bit masked used when labels are not
> wanted (attr_bitmask_nl) was not being initialized when CONFIG_NFS_V4_SECURITY_LABEL
> is not defined. Nice catch!

Oh, OK, that would explain the 0-bitmask getattr.  Thanks!

--b.
