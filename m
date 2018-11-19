Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B20E7C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 21:05:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8133F20823
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 21:05:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8133F20823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730755AbeKTHav (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 02:30:51 -0500
Received: from fieldses.org ([173.255.197.46]:57260 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729428AbeKTHav (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Nov 2018 02:30:51 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id BA32C1C82; Mon, 19 Nov 2018 16:05:23 -0500 (EST)
Date:   Mon, 19 Nov 2018 16:05:23 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <aglo@umich.edu>
Cc:     Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: handle_async_copy calling kzalloc under spinlock
Message-ID: <20181119210523.GC22976@fieldses.org>
References: <20181116142627.GA19946@fieldses.org>
 <CAN-5tyGsDAd2hkaw5nONdS2TzRy1qK7xyFDpNeT7Jsd9ZrH7+g@mail.gmail.com>
 <20181116175645.GA21852@fieldses.org>
 <20181116180118.GB21852@fieldses.org>
 <CAN-5tyGRy5vi4P-jMTmV7cto8b_6s5Cuop7dTN0Y7witpzr2pQ@mail.gmail.com>
 <CAN-5tyHX3h6TXJhFeZPGZvAWXXxwaxpAkZtRNV9+L8m5xJ3fVw@mail.gmail.com>
 <20181116193016.GA22304@fieldses.org>
 <CAN-5tyFDGnCAdQcYJRC15nsqLOmOt2c4+bZN7pEFSL-1PAx2XQ@mail.gmail.com>
 <20181116195844.GB22304@fieldses.org>
 <CAN-5tyGhkNkhU0ow8DbEm1RAjC2xiAZXwnCm5i13j-2zXHRv3A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyGhkNkhU0ow8DbEm1RAjC2xiAZXwnCm5i13j-2zXHRv3A@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 16, 2018 at 03:11:58PM -0500, Olga Kornievskaia wrote:
> On Fri, Nov 16, 2018 at 2:58 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > That race is discussed in
> > https://tools.ietf.org/html/rfc5661#section-2.10.6.3 and is supposed to
> > be dealt with by using referring triples and/or returning DELAY.
> 
> I believe those are suggestions and not mandates? A client can't rely
> that the server will implement referring sequence information. Sending
> "delay" to the server might be an option but it's an option that most
> like will interfere with performance as well?

Yes, I suppose the server either needs to implement referring triples or
retry pretty aggressively.

(By the way, I wonder if the server should always do synchronous copies
for copies smaller than a certain threshhold.  Might be hard to choose
the threshhold, though.)

> > > > And shouldn't CB_OFFLOAD be returning bad_stateid in the case it doesn't
> > > > recognize the given stateid?
> > >
> > > It could but what should the server do in this case. I would imagine
> > > it wouldn't do anything. There is nothing it can do. So now we have a
> > > copy that send the call and is going to wait on the reply which will
> > > never come as the 1st one came and we rejected it and now copy will
> > > wait forever.
> > >
> > > Please describe what "is wrong" with the current implementation.  I
> > > believe it provide a reasonable solution to the race condition.
> >
> > Looks like a server that sends bad stateids in callbacks could cause you
> > to allocate something that will never get freed.
> 
> I thought the philosophy was that client shouldn't be coded to a
> broken server. If needed, we can later on add a cleanup thread that
> goes thru the list and removes really old entries.

I suppose so.

I don't know, this design still makes me pretty uncomfortable, but I
guess I haven't come up with a strong reason it couldn't work.

--b.
