Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DDBAC0044C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 18:29:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 613C120657
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 18:29:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 613C120657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730093AbeKAD24 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 23:28:56 -0400
Received: from fieldses.org ([173.255.197.46]:54936 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729964AbeKAD24 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Oct 2018 23:28:56 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 0632D242F; Wed, 31 Oct 2018 14:29:45 -0400 (EDT)
Date:   Wed, 31 Oct 2018 14:29:45 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 01/13] fs: Don't copy beyond the end of the file
Message-ID: <20181031182945.GC3377@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-2-olga.kornievskaia@gmail.com>
 <20181031165430.GA3377@fieldses.org>
 <CAN-5tyHTZV9LYnfD9Ag_pSdWA2Zs69JNvVBjHPQTMnDm2kRuEQ@mail.gmail.com>
 <20181031175409.GB3377@fieldses.org>
 <CAN-5tyGo8BeWtGPZTd=A19+ZG3yFcGu_uu=s1MRiF6F-c+0bFw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyGo8BeWtGPZTd=A19+ZG3yFcGu_uu=s1MRiF6F-c+0bFw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Oct 31, 2018 at 02:01:45PM -0400, Olga Kornievskaia wrote:
> On Wed, Oct 31, 2018 at 1:54 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Wed, Oct 31, 2018 at 01:07:11PM -0400, Olga Kornievskaia wrote:
> > > On Wed, Oct 31, 2018 at 12:54 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > > >
> > > > On Fri, Oct 19, 2018 at 11:28:53AM -0400, Olga Kornievskaia wrote:
> > > > > From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > > >
> > > > I have some idea we've had some discussion about this before, but if so
> > > > I've forgotten the conclusion.  Could we have more of a changelog?:
> > > >
> > > >         - isn't there a race condition, or is there something preventing
> > > >           the file size from changing here?
> > >
> > > No there is nothing preventing the size from changing. Just like there
> > > is nothing that prevents the file from changing if you are doing a
> > > traditional copy either.
> > >
> > > >         - why are we doing this?  Does this change the behavior of
> > > >           copy_file_range()?
> > >
> > > We are doing this because 1. NFS spec and 2. copy_file_range semantics
> > > mandate that too. There is a whole different discussion under the
> > > client-side patch for this where the plan now is that VFS themselves
> > > are interested in making sure they are indeed enforcing the check
> > > stated by the documentation of copy_file_range call which states
> > > "copying a range beyond the end of the file" is EINVAL. I recall you
> > > argued for a "short" read instead of a EINVAL but unless VFS community
> > > is convinced to change it it'll be enforced (soon).
> >
> > OK.  Let's just make sure the reasoning's mentioned in the changelog,
> > whatever we do.
> 
> By the changelog, you mean the commit message?

Right.--b.
