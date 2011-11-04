Return-Path: linux-nfs-owner@vger.kernel.org
Received: from caiajhbdcahe.dreamhost.com ([208.97.132.74]:52229 "EHLO
	homiemail-a84.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754798Ab1KDQmP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 12:42:15 -0400
Received: from homiemail-a84.g.dreamhost.com (localhost [127.0.0.1])
	by homiemail-a84.g.dreamhost.com (Postfix) with ESMTP id 85F201DE075
	for <linux-nfs@vger.kernel.org>; Fri,  4 Nov 2011 09:42:15 -0700 (PDT)
Received: from mail-vw0-f46.google.com (mail-vw0-f46.google.com [209.85.212.46])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: nico@cryptonector.com)
	by homiemail-a84.g.dreamhost.com (Postfix) with ESMTPSA id 611B21DE071
	for <linux-nfs@vger.kernel.org>; Fri,  4 Nov 2011 09:42:15 -0700 (PDT)
Received: by vws1 with SMTP id 1so2059147vws.19
        for <linux-nfs@vger.kernel.org>; Fri, 04 Nov 2011 09:42:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4110733A-4C73-481B-96D5-D6C3BDBB16CD@netapp.com>
References: <1320269170.7734.585.camel@willson.li.ssimo.org>
	<CAK3OfOgaDjT9Smi8U1FCo=cGz5r5W2uub4xvYRqN4-9Pf-htXw@mail.gmail.com>
	<1320332310.7734.643.camel@willson.li.ssimo.org>
	<CAK3OfOhe_wZz2hKG-6HcSp_Y0=hLuRrKKb=7XOHg3sd_sz5pjw@mail.gmail.com>
	<1320337903.7734.670.camel@willson.li.ssimo.org>
	<CAK3OfOjj0GOPpeEBi4kA9jqP-vfgYqYMdv1P44H3ve0gU0hg5g@mail.gmail.com>
	<1320352784.18396.109.camel@lade.trondhjem.org>
	<CAK3OfOj5P36Z=mD4jo23kkWhzrqXEUU19Q1gDPZ0j=KiDvD1Sw@mail.gmail.com>
	<1320355818.7734.685.camel@willson.li.ssimo.org>
	<1320356806.18396.149.camel@lade.trondhjem.org>
	<1320357606.7734.697.camel@willson.li.ssimo.org>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430BFA90EE@SACMVEXC2-PRD.hq.netapp.com>
	<CAK3OfOjqCjU4O--XwVBpSBE9pwwkyBEU6OiNLN8_dM6wYe5A1w@mail.gmail.com>
	<CF863033-2ED4-4B68-B90C-54D315C67E27@netapp.com>
	<CAK3OfOgdgPEe85z152Hi06E8GwpZZJ9ch-Vq1GneMCW6nBZ6pw@mail.gmail.com>
	<4110733A-4C73-481B-96D5-D6C3BDBB16CD@netapp.com>
Date: Fri, 4 Nov 2011 11:42:14 -0500
Message-ID: <CAK3OfOjisvAjafpE04p-fFpAkqQuTgfEH5t3Ne6oTtLfYbW-rg@mail.gmail.com>
Subject: Re: GSSAPI Proxy initiative
From: Nico Williams <nico@cryptonector.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Simo Sorce <simo@redhat.com>, dhowells <dhowells@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        krbdev <krbdev@mit.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 4, 2011 at 11:30 AM, Adamson, Andy
<William.Adamson@netapp.com> wrote:
> Well, don't all GSS mechanisms have credentials? We use the UID to map between the RPCSEC_GSS context and the credential, so we don't need to store the credential along side of the context.

The problem is that for some mechs credentials can get huge over time
(e.g., Kerberos ccaches).  Ensuring that all those credentials are
available when we need them in order to reestablish RPCSEC_GSS
contexts with the server so we can WRITE out cached dirty blocks in a
memory pressure situation is... difficult or impossible -- anything we
do to make that possible will be generally brittle.

If the GSS-API gave us a way to extract a "sub-credential" we might
make do, BUT, that's ugly, IMO, and we still have to deal with the
fact that that sub-credential's expiration time might not be
convenient, thus needing extra code to refresh it proactively, and so
on.  I.e., a GSS-based solution to this problem could be a nightmare.
An RPCSEC_GSS-based solution seems trivial by comparison.

> That said, I agree that a light-weight method of re-establishing a context is very appealing.

Not least because any re--auth credential refresh operations will
involve only that client and server.

Nico
--
