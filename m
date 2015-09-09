Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47225 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752202AbbIITEe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2015 15:04:34 -0400
Date: Wed, 9 Sep 2015 15:04:34 -0400
From: Bruce James Fields <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Andrew W Elble <aweits@rit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: upgrade/downgrade race
Message-ID: <20150909190434.GC25750@fieldses.org>
References: <m2h9n3btno.fsf@discipline.rit.edu>
 <CAHQdGtQ84tUFEXaUwSngAmQst3NbjZDCSwB2jtqRqR29R4wBWg@mail.gmail.com>
 <CAHQdGtTvPPXjSm8Aq6AefMec4UEUwL6+swwav8SSFMQJMDchCA@mail.gmail.com>
 <20150909144935.51e3653b@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150909144935.51e3653b@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 09, 2015 at 02:49:35PM -0400, Jeff Layton wrote:
> On Wed, 9 Sep 2015 13:49:44 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> > +Bruce, +Jeff...
> > 
> > On Wed, Sep 9, 2015 at 1:12 PM, Trond Myklebust
> > <trond.myklebust@primarydata.com> wrote:
> > > On Wed, Sep 9, 2015 at 9:37 AM, Andrew W Elble <aweits@rit.edu> wrote:
> > >>
> > >> In attempting to troubleshoot other issues, we've run into this race
> > >> with 4.1.4 (both client and server) with a few cherry-picked patches
> > >> from upstream. This is my attempt at a redacted packet-capture.
> > >>
> > >> These all affect the same fh/stateid:
> > >>
> > >> 116 -> OPEN (will be an upgrade / for write)
> > >> 117 -> OPEN_DOWNGRADE (to read for the existing stateid / seqid = 0x6
> > >>
> > >> 121 -> OPEN_DOWNGRADE (completed last / seqid = 0x8)
> > >> 122 -> OPEN (completed first / seqid = 0x7)
> > >>
> > >> Attempts to write using that stateid fail because the stateid doesn't
> > >> have write access.
> > >>
> > >> Any thoughts? I can share more data from the capture if needed.
> > >
> > > Bruce & Jeff,
> > >
> > > Given that the client sent a non-zero seqid, why is the OPEN_DOWNGRADE
> > > being executed after the OPEN here? Surely, if that is the case, the
> > > server should be returning NFS4ERR_OLD_STATEID and failing the
> > > OPEN_DOWNGRADE operation?
> > >
> 
> The problem there is that we do the seqid checks at the beginning of
> the operation. In this case it's likely that it was 0x6 when the
> OPEN_DOWNGRADE started. The OPEN completed first though and bumped the
> seqid, and then the downgrade finished and bumped it again. When we bump
> the seqid we don't verify it against what came in originally.
> 
> The question is whether that's wrong from the POV of the spec. RFC5661
> doesn't seem to explicitly require that we serialize such operations on
> the server. The closest thing I can find is this in 3.3.12:
> 
> "The server is required to increment the "seqid" field by
>  one at each transition of the stateid.  This is important since the
>  client will inspect the seqid in OPEN stateids to determine the order
>  of OPEN processing done by the server."
> 
> If we do need to fix this on the server, it's likely to be pretty ugly:
> 
> We'd either need to serialize seqid morphing operations (ugh),

I thought that was required.

--b.

> or make
> update_stateid do an cmpxchg to swap it into place (or add some extra
> locking around it), and then have some way to unwind all of the changes
> if that fails. That may be impossible however -- we're likely closing
> struct files after all.
> 
> Now, all of that said, I think the client has some bugs in its seqid
> handling as well. It should have realized that the stateid was a r/o
> one after the OPEN_DOWNGRADE came back with the higher seqid, but it
> still issued a WRITE just afterward. That seems wrong.
> 
> -- 
> Jeff Layton <jeff.layton@primarydata.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
