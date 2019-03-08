Return-Path: <SRS0=3/9x=RL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B3C9C43381
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 21:53:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0728A20851
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Mar 2019 21:53:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=mindspring.com header.i=@mindspring.com header.b="Q12N3LhF"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726286AbfCHVxY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Mar 2019 16:53:24 -0500
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:34148 "EHLO
        elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726268AbfCHVxY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2019 16:53:24 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mindspring.com;
        s=dk12062016; t=1552082002; bh=7YSLO8XiCMm6WgJCxZZ8RvD7vlFjtuNYcOxJ
        XVEGEFc=; h=Received:From:To:Cc:References:In-Reply-To:Subject:Date:
         Message-ID:MIME-Version:Content-Type:Content-Transfer-Encoding:
         X-Mailer:Content-Language:Thread-Index:X-ELNK-Trace:
         X-Originating-IP; b=Q12N3LhF08IBCS9M/mPipH5wkJVIfdHg2vPzlDNFWICvBm
        LkAv482d/8+jRnICzLKl/ZDIlMXsxFlvAue9O2svuW8gzjLSrDZzkBj98NOoYLnoKZF
        Ticu5otwVjd6xaO3aJdhClh5I17ltpwD3vYegP1e3mRoWlk46cl/E6tLbjfDjK1VQ8n
        9OUoiZVyuJYkhH6q7I5Oe2nMH1QpD9PiUfn7Q3JIzmSCO77a/IedRQLwodBe6nwsn8c
        ni0MgzxWQ3zg6MSEig5jJgpXELReRgkouP5Zr35H+fHkU88yObgSqd1enfCxwy4Mmwv
        TCn6SeMJmBOSdu9wYX0nmWr0y4lw==
DomainKey-Signature: a=rsa-sha1; q=dns; c=nofws;
  s=dk12062016; d=mindspring.com;
  b=WKCpbMwnlhZsrMfw32Aud9dtJjO9AOD6m2OcklYNJ5hG2+K81qa8hbyjM6XZJsXEuWfthSa+hnNRYbS7sdb+Gncy64kfMrBPrpOR0+BQTg/GGhitGBTX4MhfiPTAzik1maZJ+KuKAkmyxJk0mBx7I3OZB5nUNHkG4Vbx7LDHGtUv6309q2MKMfHvYvyiHKdQeO+/si7/AEKi+ckTQ5jOs3YzCq8YDuUjsKro9Bu0OtU0QUNHXe6B/qNcqVnFf3SfYa95x3IiYAnecRjK91WSvHS0yIjxaKDovaVz64tU3aj+uEKkzCh5KO87Qp2iD9eN4GvK16yQ3pQJ4SlhrVuazQ==;
  h=Received:From:To:Cc:References:In-Reply-To:Subject:Date:Message-ID:MIME-Version:Content-Type:Content-Transfer-Encoding:X-Mailer:Content-Language:Thread-Index:X-ELNK-Trace:X-Originating-IP;
Received: from [76.105.143.216] (helo=FRANKSTHINKPAD)
        by elasmtp-mealy.atl.sa.earthlink.net with esmtpa (Exim 4)
        (envelope-from <ffilzlnx@mindspring.com>)
        id 1h2NQc-000Bgb-3V; Fri, 08 Mar 2019 16:53:18 -0500
From:   "Frank Filz" <ffilzlnx@mindspring.com>
To:     "'J. Bruce Fields'" <bfields@fieldses.org>
Cc:     "'linux-fsdevel'" <linux-fsdevel@vger.kernel.org>,
        <Volker.Lendecke@sernet.de>, <samba-technical@lists.samba.org>,
        "'Jeremy Allison'" <jra@samba.org>,
        "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>,
        "'Jeff Layton'" <jlayton@kernel.org>,
        "'Amir Goldstein'" <amir73il@gmail.com>,
        <devel@lists.nfs-ganesha.org>, "'Ralph Boehme'" <slow@samba.org>
References: <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com> <20190208155052.GB20573@fieldses.org> <CAOQ4uxg9NGPRpMZt0KgH9HUKMRpn0dFta7EnP1WioRb917n4+A@mail.gmail.com> <20190208221239.GA199180@jra3> <CAOQ4uxjxQoCWqfp+f91--tyR81PREsssT=RV9uRgCQFs+yk7mw@mail.gmail.com> <20190214210652.GC9216@fieldses.org> <20190305214748.GD27437@fieldses.org> <CAOQ4uxigRpjjni8nvYxCqeyTnr0Zf7Stj9h2+24_S9n4i0euYA@mail.gmail.com> <20190306151735.GD2426@fieldses.org> <066801d4d432$719f5df0$54de19d0$@mindspring.com> <20190308213819.GC28002@fieldses.org>
In-Reply-To: <20190308213819.GC28002@fieldses.org>
Subject: RE: [NFS-Ganesha-Devel] Re: Better interop for NFS/SMB file share mode/reservation
Date:   Fri, 8 Mar 2019 13:53:17 -0800
Message-ID: <00e901d4d5f9$57827f10$06877d30$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Mailer: Microsoft Outlook 15.0
Content-Language: en-us
Thread-Index: AQGLrJJRYR3LL3fnzQ/8W/s0P/ODKAIJU9CqAOPM+8MCWOvwNQNjSxKfAMxzl98CGloolwKYHdIRAdVHaYcCPpNDAQIx5sGhpfEovkA=
X-ELNK-Trace: 136157f01908a8929c7f779228e2f6aeda0071232e20db4dbbacfb2fd9df3c0aaf7c9ece45cf3044350badd9bab72f9c350badd9bab72f9c350badd9bab72f9c
X-Originating-IP: 76.105.143.216
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

> From: 'J. Bruce Fields' [mailto:bfields@fieldses.org]
> Sent: Friday, March 8, 2019 1:38 PM
> To: Frank Filz <ffilzlnx@mindspring.com>
> Cc: 'linux-fsdevel' <linux-fsdevel@vger.kernel.org>;
> Volker.Lendecke@sernet.de; samba-technical@lists.samba.org; 'Jeremy =
Allison'
> <jra@samba.org>; 'Linux NFS Mailing List' <linux-nfs@vger.kernel.org>; =
'Jeff
> Layton' <jlayton@kernel.org>; 'Amir Goldstein' <amir73il@gmail.com>;
> devel@lists.nfs-ganesha.org; 'Ralph Boehme' <slow@samba.org>
> Subject: [NFS-Ganesha-Devel] Re: Better interop for NFS/SMB file share
> mode/reservation
>=20
> On Wed, Mar 06, 2019 at 07:37:00AM -0800, Frank Filz wrote:
> > > On Wed, Mar 06, 2019 at 09:09:21AM +0200, Amir Goldstein wrote:
> > > > On Tue, Mar 5, 2019 at 11:48 PM J. Bruce Fields
> > > > <bfields@fieldses.org> wrote:
> > > > >
> > > > > On Thu, Feb 14, 2019 at 04:06:52PM -0500, J. Bruce Fields =
wrote:
> > > > > > After this:
> > > > > >
> > > > > >       =
https://marc.info/?l=3Dlinux-nfs&m=3D154966239918297&w=3D2
> > > > > >
> > > > > > delegations would no longer conflict with opens from the =
same
> > > > > > tgid.  So if your threads all run in the same process and
> > > > > > you're willing to manage conflicts among your own clients,
> > > > > > that should still allow you to do multiple opens of the same
> > > > > > file without giving up your
> > > lease/delegation.
> > > > > >
> > > > > > I'd be curious to know whether that works with Samba's =
design.
> > > > >
> > > > > Any idea whether that would work?
> > > > >
> > > > > (Easy?  Impossible?  Possible, but realistically the changes
> > > > > required to Samba would be painful enough that it'd be =
unlikely
> > > > > to get done?)
> > > > >
> > > >
> > > > [CC Ralph Boehme]
> > > >
> > > > I am not a samba team member, but seems to me that your proposal
> > > > fits samba design like a glove. With one smbd process per client
> > > > connection, with your proposal, opens (for read) from same smbd
> > > > process will not break the shared read lease from same client, =
so
> > > > oplocks level II could be implemented using kernel oplocks (new
> > > > flavor).
> > >
> > > OK.  So I wonder about Ganesha.  I'm not sure, but I *think* it's
> > > like knfsd in that it has a bunch of worker threads that can each
> > > take rpc's from any client.  I don't remember if they're actually
> > > threads or processes.
> >
> > Ganesha does use worker threads
>=20
> And they're all part of one process?

Sorry, should have specified, yes, Ganesha runs a single multi-threaded =
process.

> > however, one thing that may be an
> > advantage here, or at least can be leveraged, is that Ganesha =
attaches
> > a single file descriptor to each stateid. As long as the I/O =
requests
> > come using the stateid, that file descriptor will be used.
> >
> > We have some work completed and more in progress on delegations, and
> > if there becomes a new kernel oplock available, we could definitely
> > use it. On the other hand, FSAL_VFS which is the FSAL used with =
kernel
> > file systems does not support delegations...
> >
> > The (distributed) file systems we support delegations on have use
> > space libraries (which Samba should also be using?) that implement =
the
> > delegation primitives.
>=20
> Is there anyone working on delegation support for FSAL_VFS?  If it's =
not getting
> much attention then maybe Samba is the only real user for the =
forseeable
> future.

As far as I know, no one is working on delegations for FSAL_VFS. A good =
interface would make it something that might be used if it then became =
easy to implement delegations. FSAL_VFS is convenient for verifying some =
of the protocol and meta-data caching features of Ganesha.

Frank

