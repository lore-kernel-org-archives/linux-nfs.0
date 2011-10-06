Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([134.215.213.37]:2361 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755456Ab1JFUNH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Oct 2011 16:13:07 -0400
Date: Thu, 6 Oct 2011 16:12:46 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: nfsv4 <nfsv4@ietf.org>, linux-nfs <linux-nfs@vger.kernel.org>,
        nfs-ganesha-devel <nfs-ganesha-devel@lists.sourceforge.net>
Message-ID: <1412123218.108.1317931966754.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B830127@SACMVEXC2-PRD.hq.netapp.com>
Subject: Re: [nfsv4] back channel flags, CREATE_SESSION,
 BIND_CONN_TO_SESSION
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

> For whom? We have already implemented a callback model that is working
> fine for us. I have yet to see any evidence of the callback
> scalability breakdown scenario that you claim as a motivation. What I
> have (frequently) seen is scalability issues due to clients and
> servers running out of free TCP ports.

For whom?  Well, I work primarily on servers.  I have worked experimentally on the Linux v41 client.  I am pretty sure I wasn't speaking of a "callback scalability breakdown."  I was discussing a tradeoff of ports for reduced overhead of flow control, lock contention, etc.  I wasn't trying to start an inflated theory discussion about these, I don't feel fully at ease doing so.  Still, I don't intuit that potential for port exhaustion trumps other considerations, it is one consideration among several.  I also mentioned some potential benefit for server implementations, such as the one we have been collaborating on.  I'd like to maximize its potential for success.

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:
>
> My objection is to the lack of a consensus on a single system for
> implementing features. I'm tired of being told that the spec allows
> you to do the same thing in 10 different ways, with an expectation
> that we should implement all 10 ways.
> If we can't find a single good way of implementing a feature, then my
> preference is to drop support for that feature altogether (or to
> choose one implementation and to stick with it). My expectation for a
> standard is that it should aim to _reduce_ the number of different
> implementations so that we can concentrate our development and testing
> efforts. (BTW: pNFS is definitely not beyond criticism in this
> respect.)

You think the standard should influence, so as to reduce, the number of competing implementations?  Maybe you meant 'implementation choices for <x> feature.'

My expectation from NFSv4 is that there is some room for innovation and experimentation.  I don't think we can avoid this if we wish to compete effectively with ad hoc storage protocols.

>
> IOW: I can see valid reasons for why we should test the case where the
> server refuses a mixed fore+back channel, but I don't see that as a
> reason to implement a second back channel model. That requires us to
> add code + tests (and perform regular regression tests) for that back
> channel mode, as well as dealing with the case where that model of
> operation too is rejected by the server.

I find I need to keep reminding my self what "assume" does.  But I assumed that the 5661 language for negotiating a back channel was in the draft (standard) because it added value to someone, and perhaps was implemented in some environment.  If so, perhaps such a person will chime in with an opinion.

>
> Trond

Thanks,

Matt

-- 

Matt Benjamin

The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
