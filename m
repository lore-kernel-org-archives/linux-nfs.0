Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5AC4C43381
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 21:55:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 93005206DD
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 21:55:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1551909356;
	bh=eawVKdRNEhu4Ey5hiAI4DNRKt8NytWlImF5lHoMU8/E=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:List-ID:From;
	b=B0II29mPEJjmRQRR+ogFibfgKpb2yoSN9KoB3KRR0hYTEZtznEdKJ/eBeVaxdjtvn
	 C8A/UdEpiP6wjEscbo7KGN9lMCxviY5Q85N8wcJ4XuKWXLpblPo5Q5PsHdcl6DfbGv
	 yCtlu0MUZRzKAQUZSlyJ76v4Osqs+tWTXF8jXhYo=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726136AbfCFVzz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 16:55:55 -0500
Received: from mail.kernel.org ([198.145.29.99]:34840 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726082AbfCFVzz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Mar 2019 16:55:55 -0500
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 4D9AD20663;
        Wed,  6 Mar 2019 21:55:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1551909354;
        bh=eawVKdRNEhu4Ey5hiAI4DNRKt8NytWlImF5lHoMU8/E=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=AAFE3umzMoKxFbGhSNciADIn0BHMr5L3tbIovvt9WSRgJfNkFznrDXSwGYnNnr0iO
         jXUA7PxWgQ6LPGJkHsY9UEHuyhRrTAis3AprPia7HtwQ+QHoFhnFz9JvRbhGFd7yRm
         g0MFkIK24Wr7uLSnKguzR+JsXY3RA9+MC1Q4UUrw=
Message-ID: <89ff2c6c082557ab840aa4f5dd9f62c7d288e88a.camel@kernel.org>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
From:   Jeff Layton <jlayton@kernel.org>
To:     Jeremy Allison <jra@samba.org>
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Amir Goldstein <amir73il@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Volker.Lendecke@sernet.de, samba-technical@lists.samba.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        devel@lists.nfs-ganesha.org
Date:   Wed, 06 Mar 2019 16:55:51 -0500
In-Reply-To: <20190306210743.GE19279@jra3>
References: <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
         <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
         <20190208155052.GB20573@fieldses.org>
         <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
         <20190208221239.GA199180@jra3>
         <CAOQ4uxjxQoCWqfp+f91--tyR81PREsssT=RV9uRgCQFs+yk7mw@mail.gmail.com>
         <20190214210652.GC9216@fieldses.org> <20190305214748.GD27437@fieldses.org>
         <20190306151150.GC2426@fieldses.org>
         <1ade4724a4e505baf7b7c23a76e44d58b931da1f.camel@kernel.org>
         <20190306210743.GE19279@jra3>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 2019-03-06 at 13:07 -0800, Jeremy Allison wrote:
> On Wed, Mar 06, 2019 at 03:31:08PM -0500, Jeff Layton wrote:
> > On Wed, 2019-03-06 at 10:11 -0500, J. Bruce Fields wrote:
> > > On Tue, Mar 05, 2019 at 04:47:48PM -0500, J. Bruce Fields wrote:
> > > > On Thu, Feb 14, 2019 at 04:06:52PM -0500, J. Bruce Fields wrote:
> > > > > After this:
> > > > > 
> > > > > 	https://marc.info/?l=linux-nfs&m=154966239918297&w=2
> > > > > 
> > > > > delegations would no longer conflict with opens from the same tgid.  So
> > > > > if your threads all run in the same process and you're willing to manage
> > > > > conflicts among your own clients, that should still allow you to do
> > > > > multiple opens of the same file without giving up your lease/delegation.
> > > > > 
> > > > > I'd be curious to know whether that works with Samba's design.
> > > > 
> > > > Any idea whether that would work?
> > > > 
> > > > (Easy?  Impossible?  Possible, but realistically the changes required to
> > > > Samba would be painful enough that it'd be unlikely to get done?)
> > > 
> > > Volker reminds me off-list that he'd like to see Ganesha and Samba work
> > > out an API in userspace first before commiting to a user<->kernel API.
> > > 
> > > Jeff, wasn't there some work (on Ceph maybe?) on a userspace delegation
> > > API?  Is that close to what's needed?
> > > 
> > 
> > Here's the C headers for that stuff:
> > 
> >     https://github.com/ceph/ceph/blob/7ba6bece4187eda5d05a9b84211fe6ba8dd287bd/src/include/cephfs/libcephfs.h#L1734
> > 
> > It's simple enough and works for us in ganesha, and I think we can
> > probably adapt it to samba without too much difficulty. The callback
> > doesn't seem like it'll do for a kernel API though -- you'd almost
> > certainly need to do something different there (signals? inotify?).
> 
> SMB3 leases have R/RW and Handle-based leases.
> 
> Handle leases allow multiple opens of the same pathname
> that get different handles to share the lease, allowing
> a client redirector to delay opens or closes locally
> so long as it has a handle lease.
> 
> Here are the semantics:
> 
> https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-smb2/d8df943d-6ad7-4b30-9f58-96ae90fc6204
> 
> I'm not sure a simple file-descriptor based API is
> enough for us. Can he have a uuid or token based
> API instead where the server can chose what fd's
> to cover with a token ?

The libcephfs API takes an opaque void * that could hold such a token.
It gets passed back to the callback function when it's called to handle
a delegation break.

I could envision a delegation storing something similar (maybe an
unsigned long or uint64_t) and pass it back in a delegation break. With
that you could set multiple delegations on a fd, and use that to store a
key for each one.

Would something like that work for samba, or am I misunderstanding what
it needs?

-- 
Jeff Layton <jlayton@kernel.org>

