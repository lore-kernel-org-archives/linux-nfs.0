Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56530 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754755AbdLGQ6j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Dec 2017 11:58:39 -0500
Date: Thu, 7 Dec 2017 11:58:38 -0500
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Trond Myklebust <trondmy@gmail.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: [nfsv4] questing about NLM LOCK, CANCEL UNLOCK
Message-ID: <20171207165838.GA4096@fieldses.org>
References: <CAN-5tyEe2gEgmSnZju7MjgrFR_YK1PrLx2NpxJn5Ks88PEz__g@mail.gmail.com>
 <CAABAsM57k0E32ywgW=qdhFbeHctcUivM9mkuuA1qbfB9F7Rvyg@mail.gmail.com>
 <CAN-5tyEmwgo7ea1WJ-0nRE+Jz+b9rb97GkYEmFyq_C+8nr1kTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyEmwgo7ea1WJ-0nRE+Jz+b9rb97GkYEmFyq_C+8nr1kTw@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 07, 2017 at 11:10:16AM -0500, Olga Kornievskaia wrote:
> Ok. I thought that because RFC1813 covers NLM operations that it is.

Yeah, I don't see a harm to the occasional NLM question on the v4
working group list.  It's a bit of an orphaned protocol, so there's not
really any other implementation-independent forum.

> I will extend this question to the Linux NFS mailing list as the
> client implementation I'm interested is Linux.

But that's fine too.

I thought that LOCK/CANCEL race was one of the motivations for NFSv4,
so...

> >> Is there a solution or this is broken protocol?

... I'd always assumed the protocol was impossible to implement 100%
correctly, though maybe there's some clever solution.

> >> Should it be client's responsibility to notice that it received a LOCK
> >> reply for which it wasn't waiting and always follow up with an UNLOCK?

That would be tricky and still not handle all cases, I think.

--b.
