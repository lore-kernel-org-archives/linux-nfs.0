Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37922 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753708AbdJMBwY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Oct 2017 21:52:24 -0400
Date: Thu, 12 Oct 2017 21:52:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Haynes <loghyr@excfb.com>
Cc: Thomas Haynes <loghyr@primarydata.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: pynfs replay cache test SEQ9f
Message-ID: <20171013015223.GA21284@fieldses.org>
References: <1507740502-5151-1-git-send-email-Thomas.Haynes@primarydata.com>
 <E0161195-9F4A-4B36-A71D-6A924498C893@primarydata.com>
 <20171012194946.GC5233@fieldses.org>
 <6F78E570-F9B0-41A9-B224-3F2313AA8D4F@primarydata.com>
 <20171012214454.GA19598@fieldses.org>
 <20171012220051.GB29204@psyklo.internal.excfb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20171012220051.GB29204@psyklo.internal.excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 12, 2017 at 03:00:51PM -0700, Tom Haynes wrote:
> On Thu, Oct 12, 2017 at 05:44:54PM -0400, J. Bruce Fields wrote:
> > Your mailer's not quoting right, it's a little hard for me to find your
> > replies.  Wading in:
> > 
> > On Thu, Oct 12, 2017 at 09:39:04PM +0000, Thomas Haynes wrote:
> > > On Oct 12, 2017, at 12:49 PM, J. Bruce Fields <bfields@fieldses.org<mailto:bfields@fieldses.org>> wrote:
> > > > So I *think* the only correct options OK or FALSE_RETRY?
> > > 
> > > It can’t be OK if the parameters to SEQUENCE differ.
> > 
> > I'm getting that from: "When the replier detects a false retry, it is
> > permitted (but not always obligated) to return NFS4ERR_FALSE_RETRY in
> > response to the Sequence operation when it detects a false retry."
> 
> I think you are agreeing with me that OK is not appropriate here?

No, I think OK is OK:

> > If i understand the following language, we're required to return
> > FALSE_RETRY in the case the rpc credentials of the caller map to
> > different principals, but not otherwise.
> 
> This one drove me crazy:
> 
>    If a requester sent a Sequence operation with a slot ID and sequence
>    ID that are in the reply cache but the replier detected that the
>    retried request is not the same as the original request, including a
>    retry that has different operations or different arguments in the
>    operations from the original
> 
> SEQUENCE is not special - both the compounds in this example
> only have the SEQUENCE op and they differ only in that in the
> first sa_cachethis is False and in the second it is True.
> 
> So we have to return FALSE_SEQ_RETRY here...

It says "if the replier detected" a difference, not "if there is" a
difference.  So the replier is not required to do such detection.  This
agrees with the "not always obligated" above.

So I think it's allowed for the server to just return an old cached
response here (with the cached OK).  And I can't see any practical
problem that would create--a client shouldn't be sending a different
request with the same (slot, sequence) anyway.  The only potential risk
is the malicious client trying to snoop somebody else's reply cache,
hence the requirement in the case principals differ.

--b.
