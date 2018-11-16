Return-Path: <SRS0=G+EE=N3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2B41C43441
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 19:58:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A48D92086C
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 19:58:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A48D92086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726451AbeKQGMb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 17 Nov 2018 01:12:31 -0500
Received: from fieldses.org ([173.255.197.46]:52208 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725753AbeKQGMb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 17 Nov 2018 01:12:31 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 1C7B22014; Fri, 16 Nov 2018 14:58:44 -0500 (EST)
Date:   Fri, 16 Nov 2018 14:58:44 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <aglo@umich.edu>
Cc:     Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: handle_async_copy calling kzalloc under spinlock
Message-ID: <20181116195844.GB22304@fieldses.org>
References: <20181116142627.GA19946@fieldses.org>
 <CAN-5tyGsDAd2hkaw5nONdS2TzRy1qK7xyFDpNeT7Jsd9ZrH7+g@mail.gmail.com>
 <20181116175645.GA21852@fieldses.org>
 <20181116180118.GB21852@fieldses.org>
 <CAN-5tyGRy5vi4P-jMTmV7cto8b_6s5Cuop7dTN0Y7witpzr2pQ@mail.gmail.com>
 <CAN-5tyHX3h6TXJhFeZPGZvAWXXxwaxpAkZtRNV9+L8m5xJ3fVw@mail.gmail.com>
 <20181116193016.GA22304@fieldses.org>
 <CAN-5tyFDGnCAdQcYJRC15nsqLOmOt2c4+bZN7pEFSL-1PAx2XQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyFDGnCAdQcYJRC15nsqLOmOt2c4+bZN7pEFSL-1PAx2XQ@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 16, 2018 at 02:49:00PM -0500, Olga Kornievskaia wrote:
> On Fri, Nov 16, 2018 at 2:30 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Fri, Nov 16, 2018 at 01:52:29PM -0500, Olga Kornievskaia wrote:
> > > On Fri, Nov 16, 2018 at 1:30 PM Olga Kornievskaia <aglo@umich.edu> wrote:
> > > > Then how does the copy knows not to go wait for the callback? Copy
> > > > checks the pending_callback list to see if received a callback. If
> > > > not, it puts itself on the copy list and goes to sleep. The callback,
> > > > checks the copy list and if it finds a copy signals it, if not it puts
> > > > itself on the pending_callback list. a lock is held over checking one
> > > > list and putting yourself on the other.
> >
> > OK, apologies, I don't really understand those data structures yet, but
> > something seems wrong to me.
> >
> > Under what circumstances could we recieve a CB_OFFLOAD without having
> > started the corresponding copy already?
> 
> It can receive a CB_OFFLOAD before it receives a reply to the COPY.
> It's possible and I can trigger it during testing when doing a really
> short copy. The copy is done and callback thread sends a reply.
> CB_OFFLOAD call and COPY reply can be switched on the server or on the
> processing on the client.

That race is discussed in
https://tools.ietf.org/html/rfc5661#section-2.10.6.3 and is supposed to
be dealt with by using referring triples and/or returning DELAY.

> > And shouldn't CB_OFFLOAD be returning bad_stateid in the case it doesn't
> > recognize the given stateid?
> 
> It could but what should the server do in this case. I would imagine
> it wouldn't do anything. There is nothing it can do. So now we have a
> copy that send the call and is going to wait on the reply which will
> never come as the 1st one came and we rejected it and now copy will
> wait forever.
> 
> Please describe what "is wrong" with the current implementation.  I
> believe it provide a reasonable solution to the race condition.

Looks like a server that sends bad stateids in callbacks could cause you
to allocate something that will never get freed.

--b.

> > It looks like the allocation failure is
> > the *only* way we'll return an error on CB_OFFLOAD, and that seems
> > wrong.
> 
> Yes it is the only error we currently return. Do you see any other
> useful errors that a client should return (and would be useful to
> handle on the server). I don't see any need for any more
> complications.
> 
> > > > > I also wonder if SERVERFAULT is really the best error for a memory
> > > > > allocation failure there.
> > > >
> > > > I guess EIO or ENOMEM might be better. But I don't think this error
> > > > gets returned anywhere to the main process.
> > > >
> > >
> > > Wait. It is returning SERVERFAULT because it's the callback server replying
> > > back to the server's CB_RECALL call and I believe SERVERFAULT is the
> > > appropriate error here. NFS doesn't have ENOMEM error.
> >
> > We could return DELAY if we think it might be worth the server trying
> > the CB_RECALL again.  (That's what nfsd usually returns on allocation
> > failures.  I don't know if that's really ideal.)
> 
> If the client had any smarts to say correct this error that would be
> useful to return but this is not the case. I don't believe there is a
