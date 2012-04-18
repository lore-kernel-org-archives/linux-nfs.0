Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6426 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042Ab2DRPQZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 11:16:25 -0400
Date: Wed, 18 Apr 2012 11:16:38 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Peter Staubach <pstaubach@exagrid.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "miklos@szeredi.hu" <miklos@szeredi.hu>,
        "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "hch@infradead.org" <hch@infradead.org>,
        "michael.brantley@deshaw.com" <michael.brantley@deshaw.com>,
        "sven.breuner@itwm.fraunhofer.de" <sven.breuner@itwm.fraunhofer.de>
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from
 getattr call
Message-ID: <20120418111638.457f9a74@corrin.poochiereds.net>
In-Reply-To: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC063CF8E132@IT-1874.Isys.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<20120413150518.GA1987@us.ibm.com>
	<20120413114236.0e557e01@tlielax.poochiereds.net>
	<4F8B1B7B.3040304@itwm.fraunhofer.de>
	<20120416073655.7cdb90cf@corrin.poochiereds.net>
	<4F8C3036.2030702@itwm.fraunhofer.de>
	<20120416134642.1754cd3e@corrin.poochiereds.net>
	<1334604785.2879.23.camel@lade.trondhjem.org>
	<20120416154322.0d95e435@corrin.poochiereds.net>
	<1334607906.2879.36.camel@lade.trondhjem.org>
	<20120416190548.2463d1d0@corrin.poochiereds.net>
	<FA8A9A935BFD3A4D8F0CDA1C4F611BCC063CF8E115@IT-1874.Isys.com>
	<1334671736.2963.30.camel@lade.trondhjem.org.localdomain>
	<FA8A9A935BFD3A4D8F0CDA1C4F611BCC063CF8E132@IT-1874.Isys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 17 Apr 2012 10:48:42 -0400
Peter Staubach <pstaubach@exagrid.com> wrote:

> I don't think that the code ends up being all that complex, actually.  I will have to dig out the patches that I had previously to look to see what they did.  I am pretty sure that they handled all of these cases.  I also had some tests which exercised the modified path based system calls and at least, at one point in time, they would run without returning ESTALE to the user level.
> 
> Let me see what I can find.  SteveD, you wouldn't have squirrelled away a copy of my stuff from Red Hat, would you?
> 
> 	Thanx...
> 
> 		ps
> 

Yes, your original set was very comprehensive, AFAICT. I'm not sure if
it'll apply to mainline well at this point, but I was definitely using
it as a guideline for what to do here.

The cover letter for the patchset that you sent out a few years ago had
a testcase in it. I was planning to use that to test once I start
broading this to other syscalls:

    https://lkml.org/lkml/2008/3/10/267

-- 
Jeff Layton <jlayton@redhat.com>
