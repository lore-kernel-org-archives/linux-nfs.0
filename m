Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51074 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750853AbdJRVX3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 18 Oct 2017 17:23:29 -0400
Date: Wed, 18 Oct 2017 17:23:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] NFSv4.1: Fix up replays of interrupted requests
Message-ID: <20171018212329.GA29604@fieldses.org>
References: <20171011170705.45533-1-trond.myklebust@primarydata.com>
 <CAN-5tyGL1N51N7stAqxBMWZBDMQQs+BnLGd2owA1sWfpdLLFRQ@mail.gmail.com>
 <CAN-5tyEXeesbAk02LsGDjwoBqZr6q8AzWUhMSV0-V2aUwm44dA@mail.gmail.com>
 <20171016183623.GB12608@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171016183623.GB12608@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 16, 2017 at 02:36:23PM -0400, bfields wrote:
> On Mon, Oct 16, 2017 at 01:07:57PM -0400, Olga Kornievskaia wrote:
> > Network trace reveals that server is not working properly (thus
> > getting Bruce's attention here).
> > 
> > Skipping ahead, the server replies to a SEQUENCE call with a reply
> > that has a count=5 operations but only has a sequence in it.
> > 
> > The flow of steps is the following.
> > 
> > Client sends
> > call COPY seq=16 slot=0 highslot=1(application at this point receives
> > a ctrl-c so it'll go ahead and close 2files it has opened)
> 
> Is cachethis set on that the SEQUENCE op in that copy compound?
> 
> > call CLOSE  seq=1 slot=1 highslot=1
> > call SEQUENCE seq=16 slot=0 highslot=1
> > reply CLOSE OK
> > reply SEQUENCE ERR_DELAY
> > another call CLOSE seq=2 slot=1 and successful reply
> > reply COPY ..
> > call SEQUENCE seq=16 slot=0 highslot=0
> > reply SEQUENCE opcount=5
> 
> And that's the whole reply?
> 
> Do you have a binary capture that I could look at?

Thanks, yes, the client behavior is arguably out of spec (it's sending a
"retry" that doesn't match the original call), but I understand why it's
doing this, and clearly responding with a corrupted reply isn't right.
(And probably the client can deal with any reply short of one that's
actually corrupted.)  Do the following patches help?  (Actually I think
either one on its own should do the job, but I haven't done much
testing.)

--b.
