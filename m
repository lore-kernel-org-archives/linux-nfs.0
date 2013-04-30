Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34240 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760928Ab3D3QND (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Apr 2013 12:13:03 -0400
Date: Tue, 30 Apr 2013 12:13:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Steve Dickson <SteveD@redhat.com>, "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/17] lnfs: 3.9-rc8 release (take 2)
Message-ID: <20130430161300.GY17268@fieldses.org>
References: <1367240239-19326-1-git-send-email-SteveD@redhat.com>
 <20130430155740.GX17268@fieldses.org>
 <1367338308.4260.18.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1367338308.4260.18.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 30, 2013 at 04:11:50PM +0000, Myklebust, Trond wrote:
> On Tue, 2013-04-30 at 11:57 -0400, J. Bruce Fields wrote:
> > On Mon, Apr 29, 2013 at 08:57:02AM -0400, Steve Dickson wrote:
> > > From: Steve Dickson <steved@redhat.com>
> > > 
> > > Here is an updated 3.9-rc8 release of
> > > the label NFS patches. 
> > 
> > The nfsd patches look mergeable to me (with a few one-line fixes).
> > 
> > I'm missing ACKs from Trond and security folks.
> > 
> > The merge window is already open, which is late to be queueing up a
> > significant new feature.
> > 
> > It might be reasonable if we could get the needed ACKs now, but more
> > likely it looks like 3.11 to me.
> 
> I'm not going to add another 1000 lines of code to the NFS client during
> a merge window. Both Linus and Stephen (Rothwell) would throttle me if I
> did.
> 
> Let's spend this week on reviewing and making sure that all the issues
> that were reported are fixed. I'll cut a new nfs-for-next client branch
> as soon as I'm sure that is the case.

OK.

--b.
