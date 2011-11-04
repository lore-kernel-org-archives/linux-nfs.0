Return-Path: linux-nfs-owner@vger.kernel.org
Received: from caiajhbdccac.dreamhost.com ([208.97.132.202]:59726 "EHLO
	homiemail-a34.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754798Ab1KDQnW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 12:43:22 -0400
Received: from homiemail-a34.g.dreamhost.com (localhost [127.0.0.1])
	by homiemail-a34.g.dreamhost.com (Postfix) with ESMTP id 648551006D
	for <linux-nfs@vger.kernel.org>; Fri,  4 Nov 2011 09:43:16 -0700 (PDT)
Received: from mail-vx0-f174.google.com (mail-vx0-f174.google.com [209.85.220.174])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: nico@cryptonector.com)
	by homiemail-a34.g.dreamhost.com (Postfix) with ESMTPSA id B3A1B10060
	for <linux-nfs@vger.kernel.org>; Fri,  4 Nov 2011 09:43:11 -0700 (PDT)
Received: by vcbf1 with SMTP id f1so517837vcb.19
        for <linux-nfs@vger.kernel.org>; Fri, 04 Nov 2011 09:43:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1320423925.7734.732.camel@willson.li.ssimo.org>
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
	<1320423925.7734.732.camel@willson.li.ssimo.org>
Date: Fri, 4 Nov 2011 11:43:10 -0500
Message-ID: <CAK3OfOjDWd7okB=XVSZDuBDeYhc8rm=Fk4iNX3k-+W3Zf29fsg@mail.gmail.com>
Subject: Re: GSSAPI Proxy initiative
From: Nico Williams <nico@cryptonector.com>
To: Simo Sorce <simo@redhat.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        dhowells <dhowells@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        krbdev <krbdev@mit.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 4, 2011 at 11:25 AM, Simo Sorce <simo@redhat.com> wrote:
> I agree this would be a very nice feature for fast reconnects in NFSv4,
> but it looks more and more out of topic.
> Time to move this sub-thread to the NFSv4 WG ?

I agree, but I think first we need to hear agreement from the NFS
folks in this thread that we should follow this, else we should pursue
a different solution, at least for a while.
