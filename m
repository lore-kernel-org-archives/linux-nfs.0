Return-Path: <SRS0=j1eS=ND=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19428C46475
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 15:39:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BC49520671
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 15:39:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lYYGhdPB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC49520671
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728052AbeJXADi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 20:03:38 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:55676 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726970AbeJXADi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2018 20:03:38 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=MfkbRVtKwpX59qOvKhoYWyxTqEAw4vrBm3ddCfut640=; b=lYYGhdPBobjVQEh0p02aHuUMM
        omgvemGJDB5tkS5uoZcvkcKyaBdc75H9QCohV1z650aWC467AazSWLx6G7bKKeuPbdjKUpYD2atIU
        ACvCOxrQglEhp8PjOLqKEcUL0FjPVNN3nPv3saSUJeXhtV6oUf9MzuSba2EgnrlosN0D0l9wqW4/Z
        9DeNYP5z62mFYI1NHGICuIq3lUwlAadukB9kWih/vay3szP4LQpFwkZdY0OQQuGa/wdqKr2DCnVYu
        JylwYERsyWn0XDV7qsGvWdGpECAhA+YbbN86weY0qNbmQLhofvd4Mh/B84eQD1hf/EfWxSlgIDYSt
        FB5DWL4lg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gEymT-0006Vo-D0; Tue, 23 Oct 2018 15:39:41 +0000
Date:   Tue, 23 Oct 2018 08:39:41 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     Amir Goldstein <amir73il@gmail.com>,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org,
        linux-nfs <linux-nfs@vger.kernel.org>, fweimer@redhat.com,
        Steve French <smfrench@gmail.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Christoph Hellwig <hch@lst.de>,
        Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH v1 02/11] VFS permit cross device vfs_copy_file_range
Message-ID: <20181023153941.GE20085@bombadil.infradead.org>
References: <20181019153018.32507-1-olga.kornievskaia@gmail.com>
 <20181019153018.32507-2-olga.kornievskaia@gmail.com>
 <20181020040530.GG32577@ZenIV.linux.org.uk>
 <CAOQ4uxhAvypEvGap02CkH_bHtFt7tUVxTWeZUL5OV_V8xwWjDA@mail.gmail.com>
 <CAN-5tyHqtV7YhfK7DY4rY643bbfV=8MOE6=mxHYJufCsdcN9Jw@mail.gmail.com>
 <20181022190620.GA8863@bombadil.infradead.org>
 <CAN-5tyF=voE2=DBLKvJCHZc9+zMzysqD8REYYb-z5jwq2BLqGQ@mail.gmail.com>
 <a4a3ac1e840444871f3bc87606b111668c66618b.camel@redhat.com>
 <CAOQ4uxiRnyxtOXBrdCvUcTa8GkTb2OyaJYJ58Ddoik0=3Y9pyA@mail.gmail.com>
 <CAN-5tyHQc3M2YprFJm35XUxJdAx11a85o1NygE5FQFyHq3SQew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyHQc3M2YprFJm35XUxJdAx11a85o1NygE5FQFyHq3SQew@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 23, 2018 at 11:03:02AM -0400, Olga Kornievskaia wrote:
> On Tue, Oct 23, 2018 at 2:05 AM Amir Goldstein <amir73il@gmail.com> wrote:
> > On Tue, Oct 23, 2018 at 2:39 AM Jeff Layton <jlayton@redhat.com> wrote:
> > > Sorry if I wasn't clear before:
> > >
> > > Basically, I think Willy and I are both envisioning that some
> > > copy_file_range implementations may eventually not be subject to the
> > > limitations of the checks you're adding.
> > >
> >
> > Yes. Eventually. And even Matthew is (quote) "dubious" about that ever
> > happening. Changing the interface as Matthew proposed has a price
> > and we need to compare this price to the alleged backporting price
> > that nobody may ever need to pay.
> >
> > As far as I can tell, passing a struct file * on a file_operations method
> > that does not belong to that filesystem in unprecedented (*) and is a far
> > more lethal landmine than the alleged backporting landmine.
> >
> > (*) prior to v4.19-rc1, filesystems could get an overlayfs file, but
> >      file_inode(file) has always belonged to the filesystem.
> >
> > Olga,
> >
> > I do not strongly object to Matthew's proposal, so don't feel
> > obligated to choose my side of the argument. I am just trying
> > to offer a different perspective.
> >
> > In any case, my outstanding concerns with the patch are:
> >
> > 1. If you change syscall to support cross fs type copy (which is
> >     good IMO) need to document that in commit message
> >     and possibly follow up later with a note in man page
> >
> > 2. Commit message says:
> >     "This feature was of interest of ... NFS"
> >     "This feature is needed by NFSv4.2..."
> >     "NFS will allow for copies between different NFS servers."
> >     It is not clear to me if we are talking about present of future
> >     NFSv4.2 code. If NFSv4.2 currently does not support cross
> >     sb copy (??) than your patch need to enforce same sb
> >     in nfs4_copy_file_range(). If it does support cross sb copy
> >     than please edit the commit message to make that clear.
> 
> I personally agree with Amir. I think it's far fetched that a file
> system would know how to handle something that's not of its type. When
> the copy_file_range() was checked in, there was a comment above the
> superblock check saying "we might want to relax this in the future".
> It deemed appropriate then to enforce the check since none of the file
> systems used it. Now, the future is here, and we are removing the
> check but proposing a different once because again the future isn't
> here and having a single check simplifies the code.

I've done some more research and found that while NFSv4.2 has its own
representation of a copyable range of a file, iSCSI and SMB3 share the
same ROD.  So it's not at all implausible that some other filesystem
might also decide to use the same ROD, perhaps even NFS v4.3.

It's clearly crazy to expect filesystem A to know about all the
interpretations of filesystem B's file->private.  I'd expect us to add
a function like:

int vfs_get_rod(struct file *src, struct file_rod *rod);

and then a filesystem's copy_file_range() would check to see if both
src and dest referred to the same server, and if not call vfs_get_rod()
to be able to send the ROD to the destination.

