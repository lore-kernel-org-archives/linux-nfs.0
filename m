Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:20319 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754040AbaJUBG1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Oct 2014 21:06:27 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v1 13/16] NFS: Add sidecar RPC client support
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtRahOX68j6J6Vq9ykBE-2qUm1sd_HPw=HGimKAGs5V=9Q@mail.gmail.com>
Date: Mon, 20 Oct 2014 21:06:19 -0400
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Tom Talpey <tom@talpey.com>
Message-Id: <5BF0312C-06EC-4D83-81E9-F929724A0EAD@oracle.com>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net> <20141016194000.13414.83844.stgit@manet.1015granger.net> <54454762.8020506@Netapp.com> <A1CBA20C-FA2F-4E6B-9D94-75F7EFDED9C3@oracle.com> <CAHQdGtTgJ7vRR3Kw8n4K4=PSoMXV_ZQK9yFkAcK-CK5xsaTm3A@mail.gmail.com> <D259448C-9E9B-43AE-A809-A73C3C2716C5@oracle.com> <CAHQdGtRahOX68j6J6Vq9ykBE-2qUm1sd_HPw=HGimKAGs5V=9Q@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 20, 2014, at 6:31 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Mon, Oct 20, 2014 at 11:11 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> Hi Trond-
>> 
>> On Oct 20, 2014, at 3:40 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>> 
>>> Why aren't we doing the callbacks via RDMA as per the recommendation
>>> in RFC5667 section 5.1?
>> 
>> There’s no benefit to it. With a side car, the server requires
>> few or no changes. There are no CB operations that benefit
>> from using RDMA. It’s very quick to implement, re-using most of
>> the client backchannel implementation that already exists.
>> 
>> I’ve discussed this with an author of RFC 5667 [cc’d], and also
>> with the implementors of an existing NFSv4.1 server that supports
>> RDMA. They both agree that a side car is an acceptable, or even a
>> preferable, way to approach backchannel support.
>> 
>> Also, when I discussed this with you months ago, you also felt
>> that a side car was better than adding backchannel support to the
>> xprtrdma transport. I took this approach only because you OK’d it.
>> 
>> But I don’t see an explicit recommendation in section 5.1. Which
>> text are you referring to?
> 
> The very first paragraph argues that because callback messages don't
> carry bulk data, there is no problem with using RPC/RDMA and, in
> particular, with using RDMA_MSG provided that the buffer sizes are
> negotiated correctly.

The opening paragraph is advice that applies to all forms
of NFSv4 callback, including NFSv4.0, which uses a separate
transport initiated from the NFS server. Specific advice about
NFSv4.1 bi-directional RPC is left to the next two paragraphs,
but they suggest there be dragons. I rather think this is a
warning not to “go there.”

> So the questions are:
> 
> 1) Where is the discussion of the merits for and against adding
> bi-directional support to the xprtrdma layer in Linux? What is the
> showstopper preventing implementation of a design based around
> RFC5667?

There is no show-stopper (see Section 5.1, after all). It’s
simply a matter of development effort: a side-car is much
less work than implementing full RDMA backchannel support for
both a client and server, especially since TCP backchannel
already works and can be used immediately.

Also, no problem with eventually implementing RDMA backchannel
if the complexity, and any performance overhead it introduces in
the forward channel, can be justified. The client can use the
CREATE_SESSION flags to detect what a server supports.

> 2) Why do we instead have to solve the whole backchannel problem in
> the NFSv4.1 layer, and where is the discussion of the merits for and
> against that particular solution? As far as I can tell, it imposes at
> least 2 extra requirements:
> a) NFSv4.1 client+server must have support either for session
> trunking or for clientid trunking

Very minimal trunking support. The only operation allowed on
the TCP side-car's forward channel is BIND_CONN_TO_SESSION.

Bruce told me that associating multiple transports to a
clientid/session should not be an issue for his server (his
words were “if that doesn’t work, it’s a bug”).

Would this restrictive form of trunking present a problem?

> b) NFSv4.1 client must be able to set up a TCP connection to the
> server (that can be session/clientid trunked with the existing RDMA
> channel)

Also very minimal changes. The changes are already done,
posted in v1 of this patch series.

> All I've found so far on googling these questions is a 5 1/2 year old
> email exchange between Tom Tucker and Ricardo where the conclusion
> appears to be that we can, in time, implement both designs.

You and I spoke about this on Feb 13, 2014 during pub night.
At the time you stated that a side-car was the only spec-
compliant way to approach this. I said I would go forward
with the idea in Linux, and you did not object.

> However
> there is no explanation of why we would want to do so.
> http://comments.gmane.org/gmane.linux.nfs/22927

I’ve implemented exactly what Ricardo proposed in this
thread, including dealing with connection loss:

> > The thinking is that NFSRDMA could initially use a TCP callback channel.
> > We'll implement BIND_CONN_TO_SESSION so that the backchannel does not
> > need to be tied to the forechannel connection.  This should address the
> > case where you have NFSRDMA for the forechannel and TCP for the
> > backchannel.  BIND_CONN_TO_SESSION is also required to reestablish
> > dropped connections effectively (to avoid losing the reply cache).


And here’s what you had to say in support of the idea:

> Given what they're hoping to achieve, I'm fine with
> doing a simple implementation of sessions first, then progressively
> refining it.

What’s the next step?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



