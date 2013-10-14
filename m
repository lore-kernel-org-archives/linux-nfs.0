Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:52167
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756838Ab3JNPS6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 11:18:58 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Weston Andros Adamson'" <dros@netapp.com>,
        "'Anna Schumaker'" <schumaker.anna@gmail.com>
Cc: "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'Myklebust, Trond'" <Trond.Myklebust@netapp.com>,
        <linux-nfs@vger.kernel.org>,
        "'Ganesha NFS List'" <nfs-ganesha-devel@lists.sourceforge.net>
References: <1381517062-11267-1-git-send-email-dros@netapp.com> <20131011210104.GD22160@fieldses.org> <525BEDA8.3000309@gmail.com> <07F13874-0BD4-4A90-BB98-B902A8D00065@netapp.com>
In-Reply-To: <07F13874-0BD4-4A90-BB98-B902A8D00065@netapp.com>
Subject: RE: [PATCH] NFS: Add support for multiple sec= mount options
Date: Mon, 14 Oct 2013 08:18:52 -0700
Message-ID: <02a801cec8f0$b208f200$161ad600$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> >>> I wrote a script to verify that I haven't broken anything, it tests
> >>> all vers= and sec= combinations against a server with the exports:
> >>
> >> Is the script something that could be added to Anna's or my regular
> >> regression testing?
> >
> > I looked over the script Friday and I don't think it'll be too
> > difficult to work in to my Jenkins stuff :)
> 
> I have a new copy of the script that allows (almost) everything to be
passed
> in as an environment variable.
> 
> I'll hand that off to you later today.

Is this script something that would work well with Linux client against an
arbitrary server? We will eventually need to test the security negotiation
stuff with Ganesha.

Frank


