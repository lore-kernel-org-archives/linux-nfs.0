Return-Path: <SRS0=G+EE=N3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FB87C43441
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 18:30:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0B8942087A
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 18:30:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="GtRoCqDD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B8942087A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=umich.edu
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2390196AbeKQEnl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 16 Nov 2018 23:43:41 -0500
Received: from mail-vs1-f54.google.com ([209.85.217.54]:45256 "EHLO
        mail-vs1-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727462AbeKQEnl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Nov 2018 23:43:41 -0500
Received: by mail-vs1-f54.google.com with SMTP id v10so6888044vsv.12
        for <linux-nfs@vger.kernel.org>; Fri, 16 Nov 2018 10:30:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5bTMQfX3/vD0IRs6kx2NjsISxanVrQVR721uw1bB2vo=;
        b=GtRoCqDDrp3osbeUaWlDgC6i2gEXOhDpOVw6xj4pHbSGIcK41rS1lZBGFNjqQjh8Gn
         DSZWVNjlZQxulWsjR7J8Ca35GMUXlEPMBNnPoaWwy40GBRbDmnSo86mnCFro3fTchFzE
         veYKmA7TJRM6WsIi+6jtR/ulJsocEoQ36uiMbSoHdPJMJxtkRJ7q1hpe+N47mjLN38+a
         vkwXmOF3K+PBXEoqkaBOqRpp9TbE1Tj+UtdjDPWAeFNYujm160Zm7pA4waX+aQ2RtlA2
         Rs1iJSnroESN9FCPSEhycpjbsEMUmOafcA46faQYQPCiNuaM+EHvmpRKzTh7mYGFdRsz
         ddEw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=5bTMQfX3/vD0IRs6kx2NjsISxanVrQVR721uw1bB2vo=;
        b=MEXGTSxEqlgrQklzpBwBZf1m+WRDMJVbzXSE8gidcL8rFHjtBMkYza5LY14KRHk7wH
         NwbrJK+YkZyY3/N+I5tjADScFmFPKNGK4j4GTg7tAo6F+0rrODHBOXgtB8C20WzzsuMB
         /eAHPkol9gkE8OL6Jex841u1gdsWDNkcl0Wuu1Z7SMqCJ6LZka9JWh1EL5oWZJ1mH28t
         NbUid5UshymqJ8VzwAjwMgjrZ68ZqQgV72Q0ZjYoo5ipxBJ9ZWWWxJgXu5q15aSZuMFE
         ubF+6bZIoGxw+ttP11S1Qkod0g96TC7ghSu+E+/Z47J0PO+62ot6Pjusd6S5pyT3p8gk
         bPHA==
X-Gm-Message-State: AGRZ1gImWmsVr79IHjpIsuRGGEQDMJAFESPdSqGQWTbM8JGl1RQQSEYf
        mtcOq+wpHQvdjxCAyDgfbYn/Sgn29yx8hUwBdQw=
X-Google-Smtp-Source: AJdET5dvRAJtQJZxencFs6hP0gpRYBcaq7W7tgk2jo3NwCghYphKJE7PpdzBpHGCbrFQIJcG0XhpGs5ZSKPgdK1nxkM=
X-Received: by 2002:a67:a858:: with SMTP id r85mr4895523vse.215.1542393012005;
 Fri, 16 Nov 2018 10:30:12 -0800 (PST)
MIME-Version: 1.0
References: <20181116142627.GA19946@fieldses.org> <CAN-5tyGsDAd2hkaw5nONdS2TzRy1qK7xyFDpNeT7Jsd9ZrH7+g@mail.gmail.com>
 <20181116175645.GA21852@fieldses.org> <20181116180118.GB21852@fieldses.org>
In-Reply-To: <20181116180118.GB21852@fieldses.org>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Fri, 16 Nov 2018 13:30:00 -0500
Message-ID: <CAN-5tyGRy5vi4P-jMTmV7cto8b_6s5Cuop7dTN0Y7witpzr2pQ@mail.gmail.com>
Subject: Re: handle_async_copy calling kzalloc under spinlock
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 16, 2018 at 1:01 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Nov 16, 2018 at 12:56:45PM -0500, J. Bruce Fields wrote:
> > On Fri, Nov 16, 2018 at 11:25:50AM -0500, Olga Kornievskaia wrote:
> > > On Fri, Nov 16, 2018 at 9:27 AM J. Bruce Fields <bfields@fieldses.org>
> > > wrote:
> > >
> > > > From bc0c9079b48d "NFS handle COPY reply CB_OFFLOAD call race":
> > > >
> > > > +       spin_lock(&server->nfs_client->cl_lock);
> > > > +       list_for_each_entry(copy, &server->nfs_client->pending_cb_stateids,
> > > > +                               copies) {
> > > > +               if (memcmp(&res->write_res.stateid, &copy->stateid,
> > > > +                               NFS4_STATEID_SIZE))
> > > > +                       continue;
> > > > +               found_pending = true;
> > > > +               list_del(&copy->copies);
> > > > +               break;
> > > > +       }
> > > > +       if (found_pending) {
> > > > +               spin_unlock(&server->nfs_client->cl_lock);
> > > > +               goto out;
> > > > +       }
> > > >
> > > >         copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
> > > >
> > > > At this point we're still holding cl_lock.
> > > >
> > > > Best might be to allocate "copy" before taking the lock, then free it on
> > > > any
> > > > paths where we don't end up needing it.
> > > >
> > > >
> > > Thanks. I'll do that.
> >
> > Thanks.  And, I just noticed--nfs4_callback_offload has the same
> > problem.

nfs4_callback_offload is where I changed it. I see now,
handle_async_copy() in nfs42proc.c also has it.


> By the way, I don't understand the create case in that code--if you get
> a CB_OFFLOAD without already having a matching copy stateid, shouldn't
> you just return an error and forget about it?

Then how does the copy knows not to go wait for the callback? Copy
checks the pending_callback list to see if received a callback. If
not, it puts itself on the copy list and goes to sleep. The callback,
checks the copy list and if it finds a copy signals it, if not it puts
itself on the pending_callback list. a lock is held over checking one
list and putting yourself on the other.

> I also wonder if SERVERFAULT is really the best error for a memory
> allocation failure there.

I guess EIO or ENOMEM might be better. But I don't think this error
gets returned anywhere to the main process.
>
> --b.
