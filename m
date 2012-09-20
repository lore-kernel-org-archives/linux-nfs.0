Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57279 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755636Ab2ITTdv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Sep 2012 15:33:51 -0400
Date: Thu, 20 Sep 2012 15:33:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andy Adamson <androsadamson@gmail.com>
Cc: William Dauchy <wdauchy@gmail.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        R.Eggermont@tudelft.nl
Subject: Re: unhandled error -10026
Message-ID: <20120920193349.GA18143@fieldses.org>
References: <CAJ75kXZuM_p3qknD4RgdjLLWd393u02S5FKQyu3Q8y8NwmfiVw@mail.gmail.com>
 <CAJ75kXagDP6TPO+7pCCcUyac+ViPgKVThTsuehHNi_xwTpnGiQ@mail.gmail.com>
 <CAHVgHyXMR=Bf02pWe=McHZPu+iNTZvhs6vHVx1ie404QebF86g@mail.gmail.com>
 <20120920161716.GB4521@fieldses.org>
 <CAHVgHyXDs7=rafH2_pQ7T0cwzoO-LGgtVB+8E_btt5E0v9YTdg@mail.gmail.com>
 <CAHVgHyUqNWakh6h18wZDGB91GJo-crtpPjmUUB+00HTMvePRNg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHVgHyUqNWakh6h18wZDGB91GJo-crtpPjmUUB+00HTMvePRNg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 20, 2012 at 01:53:44PM -0400, Andy Adamson wrote:
> On Thu, Sep 20, 2012 at 1:47 PM, Andy Adamson <androsadamson@gmail.com> wrote:
> > On Thu, Sep 20, 2012 at 12:17 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> On Thu, Sep 20, 2012 at 12:06:48PM -0400, Andy Adamson wrote:
> >>> On Thu, Sep 20, 2012 at 10:34 AM, William Dauchy <wdauchy@gmail.com> wrote:
> >>> > On Tue, Sep 18, 2012 at 11:49 AM, William Dauchy <wdauchy@gmail.com> wrote:
> >>> >> I'm getting a trace following an unhandled error on a linux nfs client
> >>> >> 3.4.7 x86_64.
> >>> >> NFS: nfs4_reclaim_open_state: unhandled error -10026. Zeroing state
> >>> >
> >>> > For the moment I don't know if the error is coming from a bad server
> >>> > implementation or if it's on client side. Should I assume that this an
> >>> > error that should never hit the client?
> >>>
> >>> Yes.
> >>>
> >>> The client only sends OPEN reclaims after noting the server has
> >>> rebooted due to previously receiving an NFS4ERR_STALE_CLIENTID or
> >>> NFS4ERR_STALE_STATEID error from a state-full operation  (RENEW, OPEN,
> >>> OPEN_DOWNGRADE, OPEN_CONFIRM, CLOSE, LOCK, LOCKU) which triggers the
> >>> client to establish a new clientid via
> >>> SETCLIENTID/SETCLIENTID_CONFIRM.
> >>>
> >>> Upon server reboot, all state that the previous server instance had is
> >>> invalid - including OPEN seqid's. So, the server returning
> >>> NFS4ERR_BAD_SEQID (10026) on an OPEN reclaim is illegal.
> >>
> >> Wait, but couldn't there be multiple reclaims using the same open owner,
> >> in which case later reclaims could in theory hit BAD_SEQID?
> >
> > Nope.
> >
> > 3530 section 9.1.6.  Sequencing of Lock Requests
> >
> >    Note that for requests that contain a sequence number, for each
> >    state-owner, there should be no more than one outstanding request.
> 
> Well - I sent this too soon :) .  Yes, a buggy client could send
> (serialized) reclaims with a bad seqid, and get NFS4ERR_BAD_SEQ.
> Tough to do with the above constraint, but possible.

William, is this easy to reproduce?  Would it be possible to get a
network trace covering the problem?

(tcpdump -s0 -wtmp.pcap, then send us tmp.pcap.  And also feel free to
take a look at tmp.pcap with wireshark yourself--you may be able to find
the call that's returning BAD_SEQID.  What we'll be curious about is
what the sequence id sent on that call was, and what the sequence id was
on any preceding operations using the same open owner).

--b.
