From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC 0/4] nfs-utils: nfsd support for minor version
Date: Thu, 16 Apr 2009 13:24:21 -0400
Message-ID: <49E769C5.6010902@RedHat.com>
References: <49E2F6E4.2080501@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60923 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753672AbZDPR1Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Apr 2009 13:27:24 -0400
In-Reply-To: <49E2F6E4.2080501@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Benny,

Benny Halevy wrote:
> Steve, please review the following patch that add support
> for controlling the nfsv4 minor version support via
> /proc/fs/nfsd/versions.
> 
> [PATCH 1/4] utils/nfsd: fix -N optarg error printout
> 	This patch fixes an existing bug.
This is a bug... and has been committed...

> 
> [RFC 2/4] utils/nfsd: add support for minorvers4
> 	Under-the-cover support for minorvers4
I see you let minorvers4 default to zero, which means 4.1
support is off by default. Why? As long as we have away to
turn of 4.1 processing (i.e. your 4/4 patch), then I see
no reason we should have the support enabled by default. 

> 
> [RFC 3/4] utils/nfsd: add -n --nfs-version option
> 	Add a command line option to enable versions
I'm assuming you added this to be able to turn on 4.1 processing.
But 4.1 is on by default, the '-n' flag not need, correct?

> 
> [RFC 4/4] utils/nfsd: enable/disable minorvers4 via command line
> 	Extend -n/-N syntax to accept <version>.<minorversion>
look reasonable... 

steved.
