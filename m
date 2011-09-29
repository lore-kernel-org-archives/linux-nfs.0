Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46925 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755204Ab1I2R1f convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Sep 2011 13:27:35 -0400
Date: Thu, 29 Sep 2011 13:29:00 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve French <smfrench@gmail.com>
Cc: trond.myklebust@netapp.com, pavel@ucw.cz, rjw@sisk.pl,
        linux-pm@lists.linux-foundation.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, john@calva.com,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/4] cifs, freezer: add wait_event_freezekillable and
 have cifs use it
Message-ID: <20110929132900.47a7aa40@barsoom.rdu.redhat.com>
In-Reply-To: <CAH2r5ms8pg7VW7JMa_eCUomEC1cfiM+rG_JZ6F7cHB=MtZwF0A@mail.gmail.com>
References: <1317210761-11518-1-git-send-email-jlayton@redhat.com>
	<1317210761-11518-3-git-send-email-jlayton@redhat.com>
	<CAH2r5mtBwUkTXLQeXzvTC6oAcz1i9jzPGfiE7XTzDTw12A6C_Q@mail.gmail.com>
	<20110929064119.160cb455@corrin.poochiereds.net>
	<CAH2r5ms8pg7VW7JMa_eCUomEC1cfiM+rG_JZ6F7cHB=MtZwF0A@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 29 Sep 2011 11:39:53 -0500
Steve French <smfrench@gmail.com> wrote:

> On Thu, Sep 29, 2011 at 5:41 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > On Wed, 28 Sep 2011 23:28:02 -0500
> > Steve French <smfrench@gmail.com> wrote:
> >
> >> The general idea of the patch seems like a good idea to
> >> me.  Assuming testing feedback was good from the problem
> >> reporters, what tree would you want it merged from?
> >>
> >
> > There's the rub -- this requires a number of changes in different
> > areas. What I really need at this point is a verdict on patch #1. If
> > that looks OK, then that should probably go in via the one of the
> > linux-pm trees. Then patch #2 can probably go in via your tree and 3
> > and 4 can go in via Trond's.
> 
> Yes - makes sense, but wonder about ways to test the various
> suspend/hibernate cases to make sure they work.
> 

I think this set is unlikely to hurt anything (assuming of course that
waking up TASK_KILLABLE tasks on suspend events is OK). It's possible
that there are other places that need to be patched in the same way,
but this seems to cover the main pain points that people have reported.

-- 
Jeff Layton <jlayton@redhat.com>
