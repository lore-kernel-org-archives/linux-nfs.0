Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:35192 "EHLO
        elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750779AbdLGT7O (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Dec 2017 14:59:14 -0500
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Olga Kornievskaia'" <aglo@umich.edu>
Cc: "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'linux-nfs'" <linux-nfs@vger.kernel.org>, <nfsv4@ietf.org>
References: <CAN-5tyEe2gEgmSnZju7MjgrFR_YK1PrLx2NpxJn5Ks88PEz__g@mail.gmail.com> <CAABAsM57k0E32ywgW=qdhFbeHctcUivM9mkuuA1qbfB9F7Rvyg@mail.gmail.com> <CAN-5tyEmwgo7ea1WJ-0nRE+Jz+b9rb97GkYEmFyq_C+8nr1kTw@mail.gmail.com> <20171207165838.GA4096@fieldses.org> <CAN-5tyGYL5jXSqWbMSBdD9oHTD5Bsj5moFyGBKnD3t1zBLZYZA@mail.gmail.com> <019f01d36f8d$0ce06220$26a12660$@mindspring.com> <CAN-5tyGspK87j_uwzmzqZV0v3+u3KwgNObgNS+bqq-15ouskXw@mail.gmail.com>
In-Reply-To: <CAN-5tyGspK87j_uwzmzqZV0v3+u3KwgNObgNS+bqq-15ouskXw@mail.gmail.com>
Subject: RE: [nfsv4] questing about NLM LOCK, CANCEL UNLOCK
Date: Thu, 7 Dec 2017 11:59:11 -0800
Message-ID: <026e01d36f95$da192e90$8e4b8bb0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Thu, Dec 7, 2017 at 1:56 PM, Frank Filz <ffilzlnx@mindspring.com> =
wrote:
> >> On Thu, Dec 7, 2017 at 11:58 AM, J. Bruce Fields
> >> <bfields@fieldses.org>
> >> wrote:
> >> > On Thu, Dec 07, 2017 at 11:10:16AM -0500, Olga Kornievskaia =
wrote:
> >> >> Ok. I thought that because RFC1813 covers NLM operations that it =
is.
> >> >
> >> > Yeah, I don't see a harm to the occasional NLM question on the v4
> >> > working group list.  It's a bit of an orphaned protocol, so =
there's
> >> > not really any other implementation-independent forum.
> >> >
> >> >> I will extend this question to the Linux NFS mailing list as the
> >> >> client implementation I'm interested is Linux.
> >> >
> >> > But that's fine too.
> >> >
> >> > I thought that LOCK/CANCEL race was one of the motivations for
> >> > NFSv4, so...
> >> >
> >> >> >> Is there a solution or this is broken protocol?
> >> >
> >> > ... I'd always assumed the protocol was impossible to implement
> >> > 100% correctly, though maybe there's some clever solution.
> >>
> >> Is such race still possible with the linux server implementation
> >> which is
> > single
> >> threaded and in my testing isn't processing LOCK/CANCEL =
out-of-order
> then?
> >>
> >> >> >> Should it be client's responsibility to notice that it =
received
> >> >> >> a LOCK reply for which it wasn't waiting and always follow up
> >> >> >> with an
> >> UNLOCK?
> >> >
> >> > That would be tricky and still not handle all cases, I think.
> >>
> >> Yes I'm not sure the client can do it. It will have no info about =
the
> >> lock
> > and not
> >> sure how to create an appropriate UNLOCK reply (unless we keep =
around
> >> lock info of all cancelled locks).
>=20
> > The NLM4_GRANTED call has a response where the client can respond
> > NLM4_DENIED to indicate it is not accepting the lock.
> >
> > The Ganesha NFS server could process out of order, however, if the
> > client responds to the grant with NLM4_DENIED, Ganesha will properly
> > release the lock.
>=20
> This is the case for when the server is doing a callback to the client =
and
> granting the lock and client has ability to reply with denied. The =
situation I'm
> curious about is just after the initial LOCK request is sent and =
server hasn't
> processed it and it got&processed a CANCEL/UNLOCK.

Oh, woops, yea... if the lock doesn't block, then the situation is =
different. When the client gets the LOCK response, it really should =
check and see if it was actually waiting for that response, or actually, =
the client should probably delay sending UNLOCK if it has not got a =
response to an outstanding lock request yet. CANCEL is only for =
cancelling a blocked lock, so shouldn't be sent unless the server has =
already responded to the LOCK with NLM4_BLOCKED, in which case there is =
no ordering issue (Ganesha should handle ordering issue between =
NLM4_GRANT call  and NLM4_CANCEL).

If we want NLM4_CANCEL to be able to cancel an inflight LOCK request, =
then we would need to add semantics which would include the server =
either responding to the cancel to let the client know it hasn't =
processed the LOCK request yet, or it should somehow remember the cancel =
so it can ignore the LOCK request when it processes it (which is =
probably too much for the server to deal with).

> > The imperfectness of NLM is why I have seen requests for tools to =
free
> > wedged locks... We haven't managed to write such a tool for Ganesha
> > yet (so either we don't actually have that many NLM clients, or =
folks
> > are using other mechanisms to deal with the issue - restarting the
> > server and making all the clients reclaim the locks they want is one =
way to
> do it...).
>=20
> Yes server-side lock breaking or rebooting is a way out this situation =
in
> practice.
> >
> > Frank
> >
> >
> > ---
> > This email has been checked for viruses by Avast antivirus software.
> > https://www.avast.com/antivirus
> >

