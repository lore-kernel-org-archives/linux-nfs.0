Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:40393 "EHLO
        mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726008AbeIESOi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 14:14:38 -0400
Received: by mail-vk0-f43.google.com with SMTP id q184-v6so2691342vke.7
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2018 06:44:19 -0700 (PDT)
MIME-Version: 1.0
References: <87r2i8vq10.fsf@notabene.neil.brown.name> <f7f84aced6ae709b1c66e1475e8d79927fa29132.camel@hammerspace.com>
 <87o9dcvmk6.fsf@notabene.neil.brown.name>
In-Reply-To: <87o9dcvmk6.fsf@notabene.neil.brown.name>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 5 Sep 2018 09:44:07 -0400
Message-ID: <CAN-5tyG0DXosk0RUCM6E+pj-EmMWW5tuKfPg4HJChp9snvcQAQ@mail.gmail.com>
Subject: Re: NFSv4.1 session reset needs to update ->rsize and ->wsize - how???
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trondmy@hammerspace.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 4, 2018 at 8:04 PM NeilBrown <neilb@suse.com> wrote:
>
> On Tue, Sep 04 2018, Trond Myklebust wrote:
>
> > On Wed, 2018-09-05 at 08:47 +1000, NeilBrown wrote:
> >> With NFSv4.1, the server specifies max_rqst_sz and max_resp_sz in the
> >> reply to CREATE session.
> >>
> >> If the client finds it needs to call nfs4_reset_session(), it might
> >> get
> >> smaller sizes back, so any pending read/writes would need to be
> >> resized.
> >>
> >> However, I cannot see how the retry handling for reads/writes has any
> >> chance to change the size.  It looks like a request is broken up to
> >> match the original ->rsize and ->wsize, then those individual IO
> >> requests can be retried, but the higher level request is never
> >> re-evaluated in light of a new size.
> >>
> >> Am I missing something, or is this not supported at present?
> >> If it isn't supported, any suggestions on how best to handle a
> >> reduction of the rsize/wsize ??
> >>
> >
> > Why would a sane server want to do this?
>
> Why would a sane protocol support it? :-)
>
> I have a network trace of SLE11-SP4 (3.0 based) talking to "a NetApp
> appliance".
> It sends a 64K write and gets NFS4ERR_REQ_TOO_BIG.
> It then closes the file (getting NFS4ERR_SEQ_MISORDERED even though it
> used a seq number 1 more than the WRITE request), and then
> DESTROY_SESSION and CREATE_SESSION.
> The CREATE_SESSION gets "max req size" of 33812 and "max resp size" of
> 33672.
> It then opens the file again and retries the 64K write....
>
> I have a separate trace showing the initial mount where the sizes are 71680
> and 81920.
>
> I don't have a trace where it stops working, but reportedly writes work
> smoothly for some hours after a mount, but then suddenly stop working.
>
> The CREATE_SESSION *call* requests I see have the small (32K) sizes, but
> presumably they are the result of a previous CREATE_SESSION reply giving
> a small value.
>
> I just had a thought.
> If one session is shared by two "struct nfs_server" with different
> ->rsize or ->wsize, then the session might get set up with the smaller
> size, and the mount using the larger size will get confused.
> In 3.0 (and even 3.10) nfs4_init_session() limits the requested session
> parameters to ->rsize and ->wsize.
> That changed in 18aad3d552c7.
>
> Maybe I just need to remove that code from nfs4_init_session().
> I'll give it a try.
>

Neil, does the code have this commit?

commit 033853325fe3bdc70819a8b97915bd3bca41d3af
Author: Olga Kornievskaia <kolga@netapp.com>
Date:   Wed Mar 8 14:39:15 2017 -0500

    NFSv4.1 respect server's max size in CREATE_SESSION

    Currently client doesn't respect max sizes server returns in CREATE_SESSION.
    nfs4_session_set_rwsize() gets called and server->rsize, server->wsize are 0
    so they never get set to the sizes returned by the server.

    Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
    Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

> Thanks,
> NeilBrown
