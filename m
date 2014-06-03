Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752556AbaFCOKw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jun 2014 10:10:52 -0400
Date: Tue, 3 Jun 2014 10:10:21 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Anna Schumaker <schumaker.anna@gmail.com>,
        Christoph Hellwig <hch@infradead.org>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 41/52] nfsd4: turn off zero-copy-read in exotic cases
Message-ID: <20140603141021.GA14321@pad.redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
 <1400787148-25941-42-git-send-email-bfields@redhat.com>
 <20140528080945.GA6797@infradead.org>
 <20140528140151.GB13012@pad.redhat.com>
 <5385EEF5.9050904@gmail.com>
 <20140528142320.GC13012@pad.redhat.com>
 <DA524584-24CD-42C5-9DCB-B5CD2A7F2CC6@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <DA524584-24CD-42C5-9DCB-B5CD2A7F2CC6@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 03, 2014 at 12:18:34AM -0400, Weston Andros Adamson wrote:
> On May 28, 2014, at 10:23 AM, J. Bruce Fields <bfields@redhat.com> wrote:
> > There's not much point re-running all the 4.1 tests over 4.2.  Maybe all
> > we may need is to say "use minor version 2 on this compound" in tests of
> > the new features.
> > 
> > But I haven't even tried to figure out how to tell pynfs about the new
> > .x files.
> 
> I’ve made a lot of pynfs cleanups recently - mostly on the client test side 
> (the nfs4.1 server), but they may make this a bit easier. I’ll clean them up
> and share asap.
> 
> I was just adding new xdr to pynfs and AFAIK it's xdrgen has no include
> support, so we’re stuck tacking things on the end of nfs4.x. Would it be
> worthwhile for me to add some type of include support? Minor versions and
> layouts could stay in separate .x files - that sounds much cleaner to me.

That does sound cleaner, but is that how the ietf's .x files work?

It looks like

  http://www.ietf.org/id/draft-ietf-nfsv4-minorversion2-dot-x-26.txt

just copies all the 4.1 definitions.

I may not understand what you're proposing.

--b.
