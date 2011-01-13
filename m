From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Issue in nfs-utils 1.2.3
Date: Thu, 13 Jan 2011 10:52:20 -0500
Message-ID: <20110113155220.GE20946@fieldses.org>
References: <4D2D910F.1080703@onet.eu>
 <4D2DB1D8.8030606@onet.eu>
 <20110112160459.GA6124@fieldses.org>
 <2746C301-E627-4F22-8422-6A4856CF4EC0@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sdrb <sdrb-4Uo9UdwAbX8@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Steve Dickson <steved@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48939 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932979Ab1AMPwX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jan 2011 10:52:23 -0500
In-Reply-To: <2746C301-E627-4F22-8422-6A4856CF4EC0@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 13, 2011 at 10:47:42AM -0500, Chuck Lever wrote:
> 
> On Jan 12, 2011, at 11:04 AM, J. Bruce Fields wrote:
> 
> > On Wed, Jan 12, 2011 at 02:51:20PM +0100, sdrb wrote:
> >> I've investigated a little the sources and I noticed that probably
> >> there should be some pointer NULL-ed in mountlist_list() procedure
> >> like in patch I've attached.
> >> 
> >> Anyone can confirm that such a fix is ok?
> > 
> > Thanks for the report.
> > 
> > I haven't tried to verify that it could cause the backtrace you saw, but
> > clearly mlist is used after that mountlist_freeall(mlist), so your patch
> > is necessary.
> > 
> > Looks like this was introduced with a8348c2c4 "mountd: Add
> > mountlist_freeall()".
> 
> Is your theory that the introduction of a function call ( mountlist_freeall() ) hides the side-effects of that while loop, leaving the mlist variable in the mountlist_list() scope pointing at freed memory?

Yup.--b.

> 
> > --b.
> > 
> >> diff -rNup nfs-utils-1.2.3_orig/utils/mountd/rmtab.c nfs-utils-1.2.3/utils/mountd/rmtab.c
> >> --- nfs-utils-1.2.3/utils/mountd/rmtab.c	2010-09-28 14:24:16.000000000 +0200
> >> +++ nfs-utils-1.2.3/utils/mountd/rmtab.c	2011-01-12 14:44:22.320000000 +0100
> >> @@ -205,6 +205,7 @@ mountlist_list(void)
> >> 	}
> >> 	if (stb.st_mtime != last_mtime) {
> >> 		mountlist_freeall(mlist);
> >> +		mlist=NULL;
> 
> Nit: Please use white space conventions which match the rest of the file (single blanks around "=").
> 
> >> 		last_mtime = stb.st_mtime;
> >> 
> >> 		setrmtabent("r");
> > 
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
