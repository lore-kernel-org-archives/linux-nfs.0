Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58079 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751162Ab3GETwc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jul 2013 15:52:32 -0400
Date: Fri, 5 Jul 2013 15:52:26 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Disable NFS version 2
Message-ID: <20130705195225.GC8288@fieldses.org>
References: <1372856675-5520-1-git-send-email-steved@redhat.com>
 <9A7F190A-2938-4A14-9125-330189DA8597@oracle.com>
 <51D6AE7D.9070805@RedHat.com>
 <4408EEAB-97F1-404A-BC58-434729D12364@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4408EEAB-97F1-404A-BC58-434729D12364@oracle.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 05, 2013 at 10:59:59AM -0400, Chuck Lever wrote:
> Hi Steve-
> 
> On Jul 5, 2013, at 7:31 AM, Steve Dickson <SteveD@redhat.com> wrote:
> 
> > Hey,
> > 
> > On 03/07/13 09:19, Chuck Lever wrote:
> >> Hi-
> >> 
> >> I'm not opposed to this change, but we should have some public
> >> discussion about it first.
> >> 
> >> If we make this proposed upstream change, NFSv2 will be built far
> >> less often and will be a magnet for code rot.  It might make more
> >> sense to simply leave the "compile this out" choice up to
> >> distributions...?
> > Code rot is a possibility for any code where default is 'n' so that
> > means we should never use it? If that is the case, we should have
> > swap over NFS and Label NFS on be default on by default so those
> > bits don't rote... My point being, I don't think code rot should be
> > a reason for us to maintain code people should not be using in the
> > first place...
> 
> In the case at hand, code rot isn't much of a risk if the point is to
> remove a feature.  But that point wasn't stated anywhere.
> 
> >> I'd like to reduce the risk of the kernel carrying  around code
> >> that no-one uses or compiles.  If we truly want this off by default
> >> everywhere, shouldn't we just remove it?  (Is that the eventual
> >> goal?)
> > I would think so. Turn it off and see who screams.. Then get the
> > clue-bat out for for those people that do scream... ;-)  They can
> > always turn it back on... 
> 
> If deprecation is the long-term goal, we ought to have a stated plan
> that we all agree on.  We're talking about removing a feature of Linux
> NFS that has been a mainstay for, literally, decades.  Make some
> noise, let people chime in, and publish a plan so folks know what to
> expect.
> 
> We should also document publicly why we think NFSv2 support should go
> away.  Is it a significant maintenance burden?

I think the most recent motivation was the bug discussed here:

	http://thread.gmane.org/gmane.linux.nfs/52589/focus=52626

which itself was given as evidence of some continuing maintenance
burden.

> Is it a security
> problem?  Who are the stakeholders?
> 
> >> Should the server also disable NFSv2 support by default?  If not,
> >> then why is the client special in this regard?
> > We have to start somewhere... It was just easier to start with the
> > client. If Bruce is interested in dropping v2 support on the server,
> > I will be more than willing to looking into that... Actually it
> > might just be a nfs-utils only thing...
> 
> It feels like we should have a plan for both the server and client.

That discussion brought out of the woodwork a couple people still
claiming to depend on v2.  They seemed to only care about the server
side (because they had some old (non-linux) clients that were still
using v2 for some reason).

There could be other cases of people depending on an application tied to
an obsolete client OS that still expect to be able to upgrade their
server.

I may be wrong, but I'd expect the same situation (needing an obsolete
server to be able to access some data) to be rarer.  (One possible
exception I noticed is vesta: http://www.vestasys.org/--source-code
management system with built-in v2-only server.  Wonder if it's still
alive??)

Anyway I'm inclined to treat dropping server protocol support by the
same standard as we'd treat dropping kernel ABI: as in, it's only OK if
we don't expect anyone to notice.

--b.
