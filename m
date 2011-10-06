Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([134.215.213.37]:4665 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751420Ab1JFPL2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Oct 2011 11:11:28 -0400
Date: Thu, 6 Oct 2011 11:11:15 -0400 (EDT)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: nfsv4 <nfsv4@ietf.org>, linux-nfs <linux-nfs@vger.kernel.org>,
        nfs-ganesha-devel <nfs-ganesha-devel@lists.sourceforge.net>
Message-ID: <1744450629.20.1317913875236.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <832225155.16.1317913647813.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: Re: [nfsv4] back channel flags, CREATE_SESSION,
 BIND_CONN_TO_SESSION
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The rationale for making it possible to arrive at a dedicated back channel for a session is, I think, mainly that it can yield greater throughput, a benefit which grows as workload increases.  Conversely, channel negotiation appears to not have many downsides.

My reasoning would be mainly that the dedicated configuration appears to minimise the throughput potentially lost to flow control or head-of-line blocking, in particular when the the underlying transport is TCP.  A slightly different way to look at it is, that it enables a simpler RPC dispatcher at both endpoints.  (I doubt the latter is more than a short-term consideration.  Still, having an ability to work around a class of transport/interop problems transparently, which the fallback strategy could permit, might be viewed as a win.)

If one is persuaded of the potential utility of a dedicated session back channel, it still might not appear clearly better to have the client initially propose a mixed channel and assume the server will object if it cares (as opposed to making a dedicated fore channel its initial proposal).  I think the fallback strategy is slightly better.  It offers both client and server input into the transport setup, and it has the benefit of being closest to what 41 servers currently do and the Linux client currently does.

As you correctly state, the client could proceed without a back channel in the presence of a "disagreeing" server and still be conformant with RFC 5661 (if perhaps not in spirit), but actually, I'm not certain that the Linux client actually does proceed as specified in this case, as presently implemented (3.1.0-rc8)--I think it may incorrectly assume that a mixed channel has been agreed on.

Back channel negotiation does what it does, seemingly, at very little cost in development (a few hundred lines, mostly structure formulas).  Maintenance costs are said to be proportional to code size (or so I have read, e.g., Page-Jones).  I'm not making light of this point, obviously everything has a cost.

Matt

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2011-10-05 at 23:28 -0400, Trond Myklebust wrote: 
> > On Wed, 2011-10-05 at 19:21 -0400, Matt W. Benjamin wrote: 
> > > Currently, the Linux and I believe also the CITI Windows client
> always propose channels in both directions.  The Linux mainline Linux
> client doesn't know how to BIND_CONN_TO_SESSION, so trivially it won't
> negotiate any back channel if a server didn't agree to both directions
> today, either.  I've experimentally implemented a "fallback" model in
> a Linux client and (partly in a) Ganesha server.  I'd appreciate any
> feedback on the idea.
> > 
> > Yep. As I said, why should we bother adding support for servers
> that
> > don't? I can function perfectly well without pNFS support or
> delegation
> > support in such a case. Performance will suck, but why do I care?
> 
> To put it in more basic terms: what you are proposing will add
> development costs to the client and and an extra code burden to
> maintain
> long term. So what is in it for me?
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

-- 

Matt Benjamin

The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
