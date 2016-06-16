Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58522 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199AbcFPCHR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jun 2016 22:07:17 -0400
Date: Wed, 15 Jun 2016 22:07:16 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/3] nfsd state handling fixes
Message-ID: <20160616020716.GA8721@fieldses.org>
References: <1465945026.12291.5.camel@poochiereds.net>
 <1465961286-925636-1-git-send-email-green@linuxhacker.ru>
 <AAEF6AFC-06DE-46DA-A409-D69A5F8D3E3D@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AAEF6AFC-06DE-46DA-A409-D69A5F8D3E3D@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 15, 2016 at 09:54:28PM -0400, Oleg Drokin wrote:
> 
> On Jun 14, 2016, at 11:28 PM, Oleg Drokin wrote:
> 
> > These three patches do the much discussed job of making nfsd state handling
> > more robust in face of races where several opens arrive for the same file
> > at the same time from the same client.
> > 
> > This does not yet handle a case when one of those opens gets an error
> > and others don't.
> > 
> > Also this is undergoing testing ATM, so please only use it as a
> > discussion/review piece for now.
> 
> With 24 hours in testing an no problems encountered, I guess
> it's safe to declare this patchset as good to go if nobody has any
> objections against it.

Great, thanks for the testing, and all the work tracking this down;
committing for 4.7 (and the first two for stable).

--b.

> 
> > 
> > Oleg Drokin (3):
> >  nfsd: Always lock state exclusively.
> >  nfsd: Extend the mutex holding region around in nfsd4_process_open2()
> >  nfsd: Make init_open_stateid() a bit more whole
> > 
> > fs/nfsd/nfs4state.c | 67 +++++++++++++++++++++++++++++------------------------
> > fs/nfsd/state.h     |  2 +-
> > 2 files changed, 38 insertions(+), 31 deletions(-)
> > 
> > -- 
> > 2.7.4
