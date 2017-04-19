Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36546 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753375AbdDSAoF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Apr 2017 20:44:05 -0400
Date: Tue, 18 Apr 2017 20:44:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
Message-ID: <20170419004405.GA13002@fieldses.org>
References: <20170414150440.GA5362@fieldses.org>
 <20170414150940.GB5362@fieldses.org>
 <87h91mtvdb.fsf@notabene.neil.brown.name>
 <20170418171351.GF6208@fieldses.org>
 <878tmxtfne.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <878tmxtfne.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 19, 2017 at 10:17:09AM +1000, NeilBrown wrote:
> On Tue, Apr 18 2017, J. Bruce Fields wrote:
> 
> > On Tue, Apr 18, 2017 at 10:25:20AM +1000, NeilBrown wrote:
> >>  I can't say that I like this patch at all.
> >> 
> >> The problem is that:
> >> 
> >> 	pages = size / PAGE_SIZE + 1; /* extra page as we hold both request and reply.
> >> 				       * We assume one is at most one page
> >> 				       */
> >> 
> >> this assumption is never verified.
> >> To my mind, the "obvious" way to verify this assumption is that an
> >> attempt to generate a multi-page reply should fail if there was a
> >> multi-page request.
> >
> > A third option, by the way, which Ari Kauppi argued for, is adding a
> > null check each time we increment rq_next_page, since we seem to arrange
> > for the page array to always be NULL-terminated.
> 
> Not a bad idea.   That is what nfsaclsvc_encode_getaclres() and
> nfs3svc_encode_getaclres do.
> Hmm... your change to xdr_argsize_check will break
> nfsaclsvc_decode_setaclargs(), won't it?  It performs the check before
> the final nfsacl_decode().

Ugh, I forget that I don't run any tests for NFSv3 ACLs.  Well, that
would be easy enough to fix....

> >> I haven't tested this at all and haven't even convinced myself that
> >> it covers every case (though I cannot immediately think of any likely
> >> corners).
> >> 
> >> Does it address your test case?
> >
> > I'll check, it probably does.
> >
> > We'd need to limit the test to v2/v3.
> 
> Why?  Does v4 allocate extra pages?  Or is it more careful about using
> them?
> v4 does need something different, as pc_xdrressize is always zero..

NFSv4 compounds just don't have that limitation.  You can read and write
in the same compound if you want.  (Why you'd want to, I've no idea.)

(In fact, I think at least in the version >=4.1 case we should probably
only be placing limits on argument and reply sizes individually, so our
current implementation (which also places limits on the sum of the two)
is probably wrong.  This doesn't keep me up at night.)

--b.
