Return-Path: <SRS0=MTBG=NT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE25EECDE47
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 19:28:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 72491204FD
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 19:28:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72491204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725739AbeKIFEx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 9 Nov 2018 00:04:53 -0500
Received: from fieldses.org ([173.255.197.46]:38924 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725723AbeKIFEx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Nov 2018 00:04:53 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id EEEC03F4; Thu,  8 Nov 2018 14:27:59 -0500 (EST)
Date:   Thu, 8 Nov 2018 14:27:59 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 12/13] NFSD: allow inter server COPY to have a STALE
 source server fh
Message-ID: <20181108192759.GC6090@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-13-olga.kornievskaia@gmail.com>
 <20181107185753.GB19588@fieldses.org>
 <CAN-5tyH7XWsnf8VU-sMDTcxFdvk-Q7=ST5hHz=uxSk01xDk7ug@mail.gmail.com>
 <20181108192502.GB6090@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181108192502.GB6090@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 08, 2018 at 02:25:02PM -0500, J. Bruce Fields wrote:
> On Thu, Nov 08, 2018 at 01:51:58PM -0500, Olga Kornievskaia wrote:
> > On Wed, Nov 7, 2018 at 1:57 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > >
> > > On Fri, Oct 19, 2018 at 11:29:04AM -0400, Olga Kornievskaia wrote:
> > > > From: Olga Kornievskaia <kolga@netapp.com>
> > > >
> > > > The inter server to server COPY source server filehandle
> > > > is a foreign filehandle as the COPY is sent to the destination
> > > > server.
> > >
> > > Compounds can do a lot of different strange things, and I'm not
> > > convinced this code handles every case correctly.  Examples: I think
> > > that
> > >
> > >         PUTFH
> > >         TEST_STATEID
> > >         SAVEFH
> > >         COPY
> > >
> > > will incorrectly return nfserr_stale if the PUTHF gets a foreign
> > > filehandle, even though that filehandle is only used as the source of
> > > the COPY.  And:
> > >
> > >         PUTFH
> > >         SAVEFH
> > >         RENAME
> > >         COPY
> > >
> > > will pass an unverified source filehandle to rename.
> > >
> > > I can think of a couple ways to get this right for certain:
> > >
> > >         - delay all filehandle verification till the time the filehandle
> > >           isused.  That would make checking this simple, but it would
> > >           change our behavior so, for example PUTFH+READ with a bad
> > >           filehandle will return the error on the READ where it used to
> > >           return it on the PUTFH.  I don't know if that's a problem.
> > >
> > >         - somewhere at the start of nfsd4_proc_compound, do one pass
> > >           through the compound checking where the filehandles will be
> > >           used and marking those ops that can skip checking.  E.g.:
> > >
> > >                 nfsd4_op *current, *saved
> > >
> > >                 foreach op in compound:
> > >                         - if op is putfh:
> > >                                 current := op
> > >                         - if op is savefh:
> > >                                 saved := current
> > >                         - if op is restorefh:
> > >                                 current := saved
> > >                         - etc.
> > >                         - if op is copy:
> > >                                 mark_no_verify(saved)
> > >
> > >           Or something like that.
> > 
> > Do you have a preference over the 2 proposed methods? I'm not sure if
> > there is anything wrong with returning ERR_STALE  on READ instead of
> > the PUTFH but for historical reasons it seems wrong to change it. Thus
> > I'd say doing it the 2nd way is better. But then 2nd approach adds an
> > overhead of going thru operations twice for any compound. Is that
> > acceptable?
> 
> I think so.  Most compounds are pretty short and I don't think it'll be
> a big deal.

So, yes, could you try the second approach?

I've been working on the 1st approach--I have a patch here and I may
experiment with it some more.  But I'm starting to think that the
separate scan will work better.

--b.
