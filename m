Return-Path: <SRS0=nj1J=RK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6341DC4360F
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 07:48:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 30F8A2063F
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Mar 2019 07:48:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=mindspring.com header.i=@mindspring.com header.b="aqo+VFc3"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726217AbfCGHsg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Mar 2019 02:48:36 -0500
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:46596 "EHLO
        elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726170AbfCGHsg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Mar 2019 02:48:36 -0500
X-Greylist: delayed 58289 seconds by postgrey-1.27 at vger.kernel.org; Thu, 07 Mar 2019 02:48:34 EST
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mindspring.com;
        s=dk12062016; t=1551944915; bh=lL6PUyZfbSyuGM2LNmNkOi9EwZ5NV7WEAoIj
        3FOvvqU=; h=Received:From:To:Cc:References:In-Reply-To:Subject:Date:
         Message-ID:MIME-Version:Content-Type:Content-Transfer-Encoding:
         X-Mailer:Content-Language:Thread-Index:X-ELNK-Trace:
         X-Originating-IP; b=aqo+VFc3+PTrlgMeP8ASyL9CR6AZXmchlBjKyk+vnOXfMm
        AZgjbWwFE1F+PEnRWvD0y7RYmu0zywM79r3rQ8XbhlSkXsnEjD34CQpbGNGB8vYtrL7
        7+pGDTYKI09WQKEfQLfjUk9W4sucxcTKrX5C9HpDTR5kRRfpnXZrrIdJoI3W8un3Oa1
        rw3OSeTUna9OTxaddWiBoTPN5yprT+wX81Em1sWh9N6sEJNDmpcJeVjK96tOlovmqgv
        lopM2RfQEJUOblrTuVqrDifmu+Yr5sVGCqsRRFQf8wNFMXq8LZsH4Km3a2N9J+VWfLI
        Dxblypc6GNW0aDWN0JIVcmU7LkrQ==
DomainKey-Signature: a=rsa-sha1; q=dns; c=nofws;
  s=dk12062016; d=mindspring.com;
  b=C3xAE1wyideG0tsX2CicmDZ4DF6EXKYYx1jazFOKPp/Z4OWaTiYo8tEZOC8dkqTP45d/bL7sn9JHIiD/2e9+Ii0LQfQ32Xo45r30mpa5i+ZpDl5Ad8HzYeZeNvWAFgCZtWa5uJ50ei4Wx6FIUSbwVOInGNe1L3njWNpFlNTVK5G7OyCFHjJvOe2tUUsZnYICPYZEWXJvlFdboe0EPULcvyG59JYPJNu5c1BpT7wQeUFdfnPeCHUSO1UuIYI2EtSrkS1X21gqhfRtR4qsPbXYspdQJGf3J06Llsmi3eqlU6VdD1U3j9qBi/5sQ+bKQNMeDPibLwavFwW5IW4odSNLNA==;
  h=Received:From:To:Cc:References:In-Reply-To:Subject:Date:Message-ID:MIME-Version:Content-Type:Content-Transfer-Encoding:X-Mailer:Content-Language:Thread-Index:X-ELNK-Trace:X-Originating-IP;
Received: from [76.105.143.216] (helo=FRANKSTHINKPAD)
        by elasmtp-galgo.atl.sa.earthlink.net with esmtpa (Exim 4)
        (envelope-from <ffilzlnx@mindspring.com>)
        id 1h1YbN-0008kC-KM; Wed, 06 Mar 2019 10:37:01 -0500
From:   "Frank Filz" <ffilzlnx@mindspring.com>
To:     "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'Amir Goldstein'" <amir73il@gmail.com>
Cc:     <Volker.Lendecke@sernet.de>, <samba-technical@lists.samba.org>,
        "'Jeff Layton'" <jlayton@kernel.org>,
        "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>,
        "'linux-fsdevel'" <linux-fsdevel@vger.kernel.org>,
        "'Jeremy Allison'" <jra@samba.org>, <devel@lists.nfs-ganesha.org>,
        "'Ralph Boehme'" <slow@samba.org>
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com> <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org> <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com> <20190208155052.GB20573@fieldses.org> <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com> <20190208221239.GA199180@jra3> <CAOQ4uxjxQoCWqfp+f91--tyR81PREsssT=RV9uRgCQFs+yk7mw@mail.gmail.com> <20190214210652.GC9216@fieldses.org> <20190305214748.GD27437@fieldses.org> <CAOQ4uxigRpjjni8nvYxCqeyTnr0Zf7Stj9h2+24_S9n4i0euYA@mail.gmail.com> <20190306151735.GD2426@fieldses.org>
In-Reply-To: <20190306151735.GD2426@fieldses.org>
Subject: RE: [NFS-Ganesha-Devel] Re: Better interop for NFS/SMB file share mode/reservation
Date:   Wed, 6 Mar 2019 07:37:00 -0800
Message-ID: <066801d4d432$719f5df0$54de19d0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="utf-8"
Content-Transfer-Encoding: quoted-printable
X-Mailer: Microsoft Outlook 15.0
Content-Language: en-us
Thread-Index: AQKh23ZvsxK3fYh4rPpv7yCfC0etogLkxz2eAYusklECCVPQqgDjzPvDAljr8DUDY0sSnwDMc5ffAhpaKJcCmB3SEQHVR2mHo8E8B1A=
X-ELNK-Trace: 136157f01908a8929c7f779228e2f6aeda0071232e20db4dce226aa3bac61c86d54e03471dc95756350badd9bab72f9c350badd9bab72f9c350badd9bab72f9c
X-Originating-IP: 76.105.143.216
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

> On Wed, Mar 06, 2019 at 09:09:21AM +0200, Amir Goldstein wrote:
> > On Tue, Mar 5, 2019 at 11:48 PM J. Bruce Fields =
<bfields@fieldses.org> wrote:
> > >
> > > On Thu, Feb 14, 2019 at 04:06:52PM -0500, J. Bruce Fields wrote:
> > > > After this:
> > > >
> > > >       https://marc.info/?l=3Dlinux-nfs&m=3D154966239918297&w=3D2
> > > >
> > > > delegations would no longer conflict with opens from the same
> > > > tgid.  So if your threads all run in the same process and you're
> > > > willing to manage conflicts among your own clients, that should
> > > > still allow you to do multiple opens of the same file without =
giving up your
> lease/delegation.
> > > >
> > > > I'd be curious to know whether that works with Samba's design.
> > >
> > > Any idea whether that would work?
> > >
> > > (Easy?  Impossible?  Possible, but realistically the changes
> > > required to Samba would be painful enough that it'd be unlikely to
> > > get done?)
> > >
> >
> > [CC Ralph Boehme]
> >
> > I am not a samba team member, but seems to me that your proposal =
fits
> > samba design like a glove. With one smbd process per client
> > connection, with your proposal, opens (for read) from same smbd
> > process will not break the shared read lease from same client, so
> > oplocks level II could be implemented using kernel oplocks (new =
flavor).
>=20
> OK.  So I wonder about Ganesha.  I'm not sure, but I *think* it's like =
knfsd in that
> it has a bunch of worker threads that can each take rpc's from any =
client.  I don't
> remember if they're actually threads or processes.

Ganesha does use worker threads, however, one thing that may be an =
advantage here, or at least can be leveraged, is that Ganesha attaches a =
single file descriptor to each stateid. As long as the I/O requests come =
using the stateid, that file descriptor will be used.

We have some work completed and more in progress on delegations, and if =
there becomes a new kernel oplock available, we could definitely use it. =
On the other hand, FSAL_VFS which is the FSAL used with kernel file =
systems does not support delegations...

The (distributed) file systems we support delegations on have use space =
libraries (which Samba should also be using?) that implement the =
delegation primitives.

> > IOW, can someone from samba team please elaborate on this quote from
> > samba wiki [1]: "Linux kernel oplocks don't provide the needed =
features.
> > (They don't even work correctly for oplocks...) =3D=3D> SMB-only =
feature."
> >
> > [1] https://wiki.samba.org/index.php/Samba3/SMB2#new_concepts
>=20
> Yes, it'd be useful to get those details written down in one place.
>=20
> > I would like to use this opportunity to ask samba team members to
> > raise any (*) other pain points about missing or lacking Linux =
kernel interfaces.
> > I promise to use my time in LSF/MM 2019 to try and promote samba =
needs
> > among Linux filesystem developers.
>=20
> I feel like this particular problem is about details of =
oplock/lease/delegation
> semantics that will interest a small number of people, so should =
mainly be
> handled as a hallway-track thing.  But, maybe it's good to bring it up =
in a session
> if only to make sure anyone interested is aware.
>=20
> > (*) OK, not RichACLs. I know my own limitations.
>=20
> Hah.

:-)

Frank

