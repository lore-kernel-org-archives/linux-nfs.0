Return-Path: linux-nfs-owner@vger.kernel.org
Received: from caiajhbdcbef.dreamhost.com ([208.97.132.145]:56807 "EHLO
	homiemail-a88.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932185Ab1KDPgM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 11:36:12 -0400
Received: from homiemail-a88.g.dreamhost.com (localhost [127.0.0.1])
	by homiemail-a88.g.dreamhost.com (Postfix) with ESMTP id D1593264070
	for <linux-nfs@vger.kernel.org>; Fri,  4 Nov 2011 08:36:11 -0700 (PDT)
Received: from mail-vx0-f174.google.com (mail-vx0-f174.google.com [209.85.220.174])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: nico@cryptonector.com)
	by homiemail-a88.g.dreamhost.com (Postfix) with ESMTPSA id A4F7D264063
	for <linux-nfs@vger.kernel.org>; Fri,  4 Nov 2011 08:36:11 -0700 (PDT)
Received: by vcbf1 with SMTP id f1so449004vcb.19
        for <linux-nfs@vger.kernel.org>; Fri, 04 Nov 2011 08:36:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAK3OfOjqCjU4O--XwVBpSBE9pwwkyBEU6OiNLN8_dM6wYe5A1w@mail.gmail.com>
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
Date: Fri, 4 Nov 2011 10:36:11 -0500
Message-ID: <CAK3OfOihQhpzDriUwDQMdWahyOboHRX1vs0aYGTi8kG8ket1dg@mail.gmail.com>
Subject: Re: GSSAPI Proxy initiative
From: Nico Williams <nico@cryptonector.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Simo Sorce <simo@redhat.com>, dhowells <dhowells@redhat.com>,
        linux-nfs@vger.kernel.org, krbdev <krbdev@mit.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also, the recovery issue can come up with the server's cache of
RPCSEC_GSS contexts is under pressure.

I really think we want an RPCSEC_GSS-level solution for this.  I don't
think we can address this problem entirely in the GSS stack.  Since
RPCSEC_GSSv3 isn't done yet, maybe now is the time to work on a
solution there.

I'd build the solution by borrowing tech from Kerberos.  The server
would mint a ticket for itself using some local secret key for the
ticket's encrypted part and with authorization data storing all of the
relevant server-side authorization context for the client principal,
then the server sends a KRB-CRED with that ticket and session key with
the KRB-CRED wrapped in a GSS wrap token OR with an encryption key for
the KRB-CRED based on GSS_Pseudo_random() OR it sends the ticket and
the client uses GSS_Pseudo_random() to compute the same session key
that the server did.

Nico
--
