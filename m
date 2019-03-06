Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 546C4C43381
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 15:17:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2D6FF20675
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 15:17:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727760AbfCFPRg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 10:17:36 -0500
Received: from fieldses.org ([173.255.197.46]:41716 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729706AbfCFPRg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Mar 2019 10:17:36 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 862D71C82; Wed,  6 Mar 2019 10:17:35 -0500 (EST)
Date:   Wed, 6 Mar 2019 10:17:35 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     Jeremy Allison <jra@samba.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Volker.Lendecke@sernet.de, Jeff Layton <jlayton@kernel.org>,
        samba-technical@lists.samba.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Ralph Boehme <slow@samba.org>, devel@lists.nfs-ganesha.org
Subject: Re: Better interop for NFS/SMB file share mode/reservation
Message-ID: <20190306151735.GD2426@fieldses.org>
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
 <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
 <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
 <20190208155052.GB20573@fieldses.org>
 <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com>
 <20190208221239.GA199180@jra3>
 <CAOQ4uxjxQoCWqfp+f91--tyR81PREsssT=RV9uRgCQFs+yk7mw@mail.gmail.com>
 <20190214210652.GC9216@fieldses.org>
 <20190305214748.GD27437@fieldses.org>
 <CAOQ4uxigRpjjni8nvYxCqeyTnr0Zf7Stj9h2+24_S9n4i0euYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxigRpjjni8nvYxCqeyTnr0Zf7Stj9h2+24_S9n4i0euYA@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Mar 06, 2019 at 09:09:21AM +0200, Amir Goldstein wrote:
> On Tue, Mar 5, 2019 at 11:48 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Thu, Feb 14, 2019 at 04:06:52PM -0500, J. Bruce Fields wrote:
> > > After this:
> > >
> > >       https://marc.info/?l=linux-nfs&m=154966239918297&w=2
> > >
> > > delegations would no longer conflict with opens from the same tgid.  So
> > > if your threads all run in the same process and you're willing to manage
> > > conflicts among your own clients, that should still allow you to do
> > > multiple opens of the same file without giving up your lease/delegation.
> > >
> > > I'd be curious to know whether that works with Samba's design.
> >
> > Any idea whether that would work?
> >
> > (Easy?  Impossible?  Possible, but realistically the changes required to
> > Samba would be painful enough that it'd be unlikely to get done?)
> >
> 
> [CC Ralph Boehme]
> 
> I am not a samba team member, but seems to me that your proposal
> fits samba design like a glove. With one smbd process per client connection,
> with your proposal, opens (for read) from same smbd process will not break the
> shared read lease from same client, so oplocks level II could be implemented
> using kernel oplocks (new flavor).

OK.  So I wonder about Ganesha.  I'm not sure, but I *think* it's like
knfsd in that it has a bunch of worker threads that can each take rpc's
from any client.  I don't remember if they're actually threads or
processes.

> IOW, can someone from samba team please elaborate on this quote
> from samba wiki [1]: "Linux kernel oplocks don't provide the needed features.
> (They don't even work correctly for oplocks...) ==> SMB-only feature."
> 
> [1] https://wiki.samba.org/index.php/Samba3/SMB2#new_concepts

Yes, it'd be useful to get those details written down in one place.

> I would like to use this opportunity to ask samba team members to raise
> any (*) other pain points about missing or lacking Linux kernel interfaces.
> I promise to use my time in LSF/MM 2019 to try and promote samba
> needs among Linux filesystem developers.

I feel like this particular problem is about details of
oplock/lease/delegation semantics that will interest a small number of
people, so should mainly be handled as a hallway-track thing.  But,
maybe it's good to bring it up in a session if only to make sure anyone
interested is aware.

> (*) OK, not RichACLs. I know my own limitations.

Hah.

--b.
