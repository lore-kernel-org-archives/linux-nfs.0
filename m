Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42630 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755605Ab3BWNBW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 Feb 2013 08:01:22 -0500
Date: Sat, 23 Feb 2013 08:01:19 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFSDv4.2: Added NFS v4.2 support to the NFS server
Message-ID: <20130223130119.GB5710@fieldses.org>
References: <1361552981-29385-1-git-send-email-steved@redhat.com>
 <1361552981-29385-3-git-send-email-steved@redhat.com>
 <20130222180515.GA30856@fieldses.org>
 <5128B97F.6040301@RedHat.com>
 <20130223130056.GA5710@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130223130056.GA5710@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 23, 2013 at 08:00:56AM -0500, J. Bruce Fields wrote:
> On Sat, Feb 23, 2013 at 07:43:43AM -0500, Steve Dickson wrote:
> > 
> > 
> > On 22/02/13 13:05, J. Bruce Fields wrote:
> > > On Fri, Feb 22, 2013 at 12:09:41PM -0500, Steve Dickson wrote:
> > >> > This enable NFSv4.2 support for the server. To enable this
> > >> > code do the following:
> > >> >   echo "+4.2" >/proc/fs/nfsd/versions
> > > Give it a config option and we're set....
> > I didn't a config option in fs/nfsd/Kconfig for 4.1 which is 
> > the reason I didn't add one for 4.2... Should I add both?
> 
> Well.... I guess if it defaults to off at runtime, and if there's a
> config option for labeled NFS--maybe there's no harm to it.  At worst
> somebody turns on 4.2 by option but hey it should be fully
> spec-compliant as 4.2 is only optional stuff.

(In other words: OK, OK, never mind, we can do without!)

--b.
