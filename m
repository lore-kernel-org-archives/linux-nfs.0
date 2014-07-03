Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f173.google.com ([209.85.220.173]:42539 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759469AbaGCQ2F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 12:28:05 -0400
Received: by mail-vc0-f173.google.com with SMTP id lf12so465776vcb.32
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jul 2014 09:28:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140703161140.GA2645@infradead.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
	<1404143423-24381-16-git-send-email-jlayton@primarydata.com>
	<20140703151819.GC24322@fieldses.org>
	<20140703112050.61c1561d@tlielax.poochiereds.net>
	<20140703153208.GD24322@fieldses.org>
	<20140703161140.GA2645@infradead.org>
Date: Thu, 3 Jul 2014 12:28:04 -0400
Message-ID: <CAHQdGtQXtbsR1iAit49TP=k1H=r-Wa7aPRP5+Ur+ohstxLyH3Q@mail.gmail.com>
Subject: Re: [PATCH v3 015/114] nfsd: Allow struct nfsd4_compound_state to
 cache the nfs4_client
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 3, 2014 at 12:11 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Thu, Jul 03, 2014 at 11:32:08AM -0400, J. Bruce Fields wrote:
>> > > > +       struct nfs4_client *found;
>> > > > +
>> > > > +       if (cstate->clp) {
>> > > > +               found = cstate->clp;
>> > > > +               if (!same_clid(&found->cl_clientid, clid))
>> > > > +                       return nfserr_stale_clientid;
>> > >
>> > > That's new behavior, isn't it?
>> > >
>> >
>> > Yeah, I suppose it is, but it's hard to understand a valid use-case for
>> > sending multiple ops in a compound with different clientids. Certainly
>> > no well-behaved client would do that, would it? (Hmm, that might be an
>> > interesting pynfs test, come to think of it).
>>
>> We could ask for a clarification in 3530bis if there's not already
>> something there that clearly forbids this, but I'm not sure if it's even
>> worth it.
>
> Or just handle it and be done with me.  After all we'd just need to put
> the existing client, and store the new one in the cstate.

It is definitely not allowed in NFSv4.1. There is a special place in
hell^W^W^Werrorcode NFS4ERR_SEQUENCE_POS that tells you that your
compound is insane.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
