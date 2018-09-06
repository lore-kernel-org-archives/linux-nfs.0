Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua1-f48.google.com ([209.85.222.48]:43464 "EHLO
        mail-ua1-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727768AbeIFVkN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Sep 2018 17:40:13 -0400
Received: by mail-ua1-f48.google.com with SMTP id f4-v6so9474767uao.10
        for <linux-nfs@vger.kernel.org>; Thu, 06 Sep 2018 10:03:49 -0700 (PDT)
MIME-Version: 1.0
References: <87r2i8vq10.fsf@notabene.neil.brown.name> <f7f84aced6ae709b1c66e1475e8d79927fa29132.camel@hammerspace.com>
 <87o9dcvmk6.fsf@notabene.neil.brown.name> <CAN-5tyG0DXosk0RUCM6E+pj-EmMWW5tuKfPg4HJChp9snvcQAQ@mail.gmail.com>
 <87lg8fveb9.fsf@notabene.neil.brown.name>
In-Reply-To: <87lg8fveb9.fsf@notabene.neil.brown.name>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 6 Sep 2018 13:03:36 -0400
Message-ID: <CAN-5tyE2SM92Ntj+i0zbxd9-DeFWEeXbMxD-akh5+aiYqgEN5A@mail.gmail.com>
Subject: Re: NFSv4.1 session reset needs to update ->rsize and ->wsize - how???
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trondmy@hammerspace.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 5, 2018 at 5:12 PM NeilBrown <neilb@suse.com> wrote:
>
> On Wed, Sep 05 2018, Olga Kornievskaia wrote:
>
> > On Tue, Sep 4, 2018 at 8:04 PM NeilBrown <neilb@suse.com> wrote:
> >>
> >> On Tue, Sep 04 2018, Trond Myklebust wrote:
> >>
> >> > On Wed, 2018-09-05 at 08:47 +1000, NeilBrown wrote:
> >> >> With NFSv4.1, the server specifies max_rqst_sz and max_resp_sz in the
> >> >> reply to CREATE session.
> >> >>
> >> >> If the client finds it needs to call nfs4_reset_session(), it might
> >> >> get
> >> >> smaller sizes back, so any pending read/writes would need to be
> >> >> resized.
> >> >>
> >> >> However, I cannot see how the retry handling for reads/writes has any
> >> >> chance to change the size.  It looks like a request is broken up to
> >> >> match the original ->rsize and ->wsize, then those individual IO
> >> >> requests can be retried, but the higher level request is never
> >> >> re-evaluated in light of a new size.
> >> >>
> >> >> Am I missing something, or is this not supported at present?
> >> >> If it isn't supported, any suggestions on how best to handle a
> >> >> reduction of the rsize/wsize ??
> >> >>
> >> >
> >> > Why would a sane server want to do this?
> >>
> >> Why would a sane protocol support it? :-)
> >>
> >> I have a network trace of SLE11-SP4 (3.0 based) talking to "a NetApp
> >> appliance".
> >> It sends a 64K write and gets NFS4ERR_REQ_TOO_BIG.
> >> It then closes the file (getting NFS4ERR_SEQ_MISORDERED even though it
> >> used a seq number 1 more than the WRITE request), and then
> >> DESTROY_SESSION and CREATE_SESSION.
> >> The CREATE_SESSION gets "max req size" of 33812 and "max resp size" of
> >> 33672.
> >> It then opens the file again and retries the 64K write....
> >>
> >> I have a separate trace showing the initial mount where the sizes are 71680
> >> and 81920.
> >>
> >> I don't have a trace where it stops working, but reportedly writes work
> >> smoothly for some hours after a mount, but then suddenly stop working.
> >>
> >> The CREATE_SESSION *call* requests I see have the small (32K) sizes, but
> >> presumably they are the result of a previous CREATE_SESSION reply giving
> >> a small value.
> >>
> >> I just had a thought.
> >> If one session is shared by two "struct nfs_server" with different
> >> ->rsize or ->wsize, then the session might get set up with the smaller
> >> size, and the mount using the larger size will get confused.
> >> In 3.0 (and even 3.10) nfs4_init_session() limits the requested session
> >> parameters to ->rsize and ->wsize.
> >> That changed in 18aad3d552c7.
> >>
> >> Maybe I just need to remove that code from nfs4_init_session().
> >> I'll give it a try.
> >>
> >
> > Neil, does the code have this commit?
> >
> > commit 033853325fe3bdc70819a8b97915bd3bca41d3af
> > Author: Olga Kornievskaia <kolga@netapp.com>
> > Date:   Wed Mar 8 14:39:15 2017 -0500
> >
> >     NFSv4.1 respect server's max size in CREATE_SESSION
> >
> >     Currently client doesn't respect max sizes server returns in CREATE_SESSION.
> >     nfs4_session_set_rwsize() gets called and server->rsize, server->wsize are 0
> >     so they never get set to the sizes returned by the server.
> >
> >     Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> >     Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> >
> >> Thanks,
> >> NeilBrown
>
> Thanks for the suggestion.
> The kernel doesn't have that patch, but I don't think it is relevant.
> The ->rsize does have a suitable value - it isn't zero.
> The problem is that the session limit appears to change, and the client
> doesn't adjust to the change.
>
> My current theory is that the client actually requested the change,
> though on behalf of a different filesystem using the same session.

I think the patch is relevant. I think what you described points to
the exact same problem the commit addresses.

Netapp server can return a size smaller than the client has requested.
Without that patch, the client will ignore what the server sent and
will use the value the client has sent. While the patch might not have
fixed it the 'correct' way (and the location of
nfs4_session_set_rwsize() should have been called at a different
place. It does seem to fix the problem (according to testing).

Netapp does not recommend changing  the rsize on the server side but
it is theoretically possible (and I know of customer who have used it)
and if some error flow ends up re-creating a session, without this
patch, you will see this problem because the client will send a higher
value then the server can support.
