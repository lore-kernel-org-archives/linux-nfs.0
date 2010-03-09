Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55999 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752108Ab0CIPJ3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Mar 2010 10:09:29 -0500
Date: Tue, 9 Mar 2010 10:10:53 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: reboot recovery
Message-ID: <20100309151053.GC21862@fieldses.org>
References: <20100309014624.GF2999@fieldses.org> <ABA6EE88-3584-4DC9-A50B-3B0E06C701FB@netapp.com> <20100309145354.GB21862@fieldses.org> <89c397151003090655h7f3465f2u36c60cfa0b580516@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <89c397151003090655h7f3465f2u36c60cfa0b580516@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 09, 2010 at 09:55:52AM -0500, William A. (Andy) Adamson wrote:
> On Tue, Mar 9, 2010 at 9:53 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Tue, Mar 09, 2010 at 09:46:04AM -0500, Andy Adamson wrote:
> >>
> >> RFC 5661 in section 18.51.3
> >>
> >>    Whenever a client establishes a new client ID and before it does the
> >>    first non-reclaim operation that obtains a lock, it MUST send a
> >>    RECLAIM_COMPLETE with rca_one_fs set to FALSE, even if there are no
> >>    locks to reclaim.  If non-reclaim locking operations are done before
> >>    the RECLAIM_COMPLETE, an NFS4ERR_GRACE error will be returned.
> >>
> >> So there will never be a 'first OPEN' (except for an OPEN reclaim)
> >> without a RECLAIM_COMPLETE.
> >
> > There will be in the case of an entirely new client, or a client that
> > missed the grace period completely.
> 
> No, the MUST above applies to both a new client/client that missed the
> grace period completely. In both cases the client is establishing a
> new client ID.

Oog, sorry, obviously I can't read--I see what you mean now.

I haven't seen any client send a RECLAIM_COMPLETE or any server demand
one yet, so do we all have this wrong?

Or was the above a mistake and they meant to say something like
"whenever a client *that previously held state* establishes a new client
ID...."?

--b.
