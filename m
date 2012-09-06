Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24720 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756295Ab2IFPFn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Sep 2012 11:05:43 -0400
Message-ID: <1346943940.2562.9.camel@localhost>
Subject: Re: [PATCH] Avoid array overflow in __nfs4_get_acl_uncached
From: Sachin Prabhu <sprabhu@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 06 Sep 2012 16:05:40 +0100
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908F8B010@SACEXCMBX04-PRD.hq.netapp.com>
References: <1345817768-23511-1-git-send-email-sprabhu@redhat.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F4AF1E@SACEXCMBX01-PRD.hq.netapp.com>
	 <1345843866.2279.6.camel@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F5842F@SACEXCMBX01-PRD.hq.netapp.com>
	 <1345845062.32200.1.camel@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F5859F@SACEXCMBX01-PRD.hq.netapp.com>
	 <1345937503.4943.17.camel@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F69340@SACEXCMBX04-PRD.hq.netapp.com>
	 <1346162966.2554.3.camel@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F81C4A@SACEXCMBX04-PRD.hq.netapp.com>
	 <1346942761.2562.7.camel@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F8B010@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2012-09-06 at 14:53 +0000, Myklebust, Trond wrote:
> On Thu, 2012-09-06 at 15:46 +0100, Sachin Prabhu wrote:
> > On Mon, 2012-09-03 at 19:11 +0000, Myklebust, Trond wrote:
> > > > I encountered 2 problems. 
> > > > 1) The if condition should be srclen >= pgbase + acl_len
> > > > 2) There is a second _copy_from_pages which copies to the the acl to the
> > > > passed buffer in __nfs4_get_acl_uncached().
> > > 
> > > The second copy from pages should already be covered by the checks in
> > > decode_getacl. Alright, since this is not obvious, then clearly we need
> > > to make it so. How about the following?
> > 
> > I could reproduce the crash with the second _copy_from_pages using the
> > patch to PyNFS from
> > http://www.spinics.net/lists/linux-nfs/msg32359.html
> > 
> > The patch below works fine for both cases apart from a small bug which
> > I've pointed to below.
> > 
> > > 8<------------------------------------------------------------------
> > > From 5040240245a046bd58c383806b3f161ee8b5823b Mon Sep 17 00:00:00 2001
> > > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > Date: Sun, 26 Aug 2012 11:44:43 -0700
> > > Subject: [PATCH] NFSv4: Fix buffer overflow checking in
> > >  __nfs4_get_acl_uncached
> 
> > > +		/* Check for receive buffer overflow */
> > > +		if (attrlen > (xdr->nwords << 2) ||
> > > +		    attrlen + pg_offset > xdr->buf->page_len) {
> > 
> > Here we need to use res->acl_data_offset which points to the start of
> > the ACL data instead of pg_offset which points to the start of the pages
> > section of the xdr_buf.
> > 
> > Once I changed this if condition, I was able to successfully test with
> > my reproducer.
> 
> Oops... Yes, of course you are right. I'll make the modification and
> push out the changed patch.
> 
> Thanks very much for testing! Do you want me to add a "Tested-by:" line?
> 

Fine by me.

Sachin Prabhu

