Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f195.google.com ([209.85.166.195]:54702 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727941AbeJEXKV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Oct 2018 19:10:21 -0400
Received: by mail-it1-f195.google.com with SMTP id l191-v6so3275932ita.4
        for <linux-nfs@vger.kernel.org>; Fri, 05 Oct 2018 09:11:00 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
Message-ID: <10dee831d3ce0041115f3e33b2df17fdff2b26a7.camel@hammerspace.com>
Subject: Re: [PATCH RFC] nfs: make DELEGRETURN try harder to determine if a
 delegation has been revoked
To: Andrew W Elble <aweits@rit.edu>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <m2sh1kbekr.fsf@discipline.rit.edu>
References: <20181005133429.79332-1-aweits@rit.edu>
         <04588fc1ef331c111185cb2f940d20a2e183e598.camel@hammerspace.com>
         <8b5d00b03e9a2fc20ebb3c6e3e040f3225beed22.camel@hammerspace.com>
         <m2sh1kbekr.fsf@discipline.rit.edu>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Date: Fri, 05 Oct 2018 12:10:51 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2018-10-05 at 11:25 -0400, Andrew W Elble wrote:
> > > NACK. We don't ever want to run synchronous RPC calls from inside
> > > an
> > > rpciod context. There be deadlocks...
> 
> ahhh yes, I missed the fact that nfs4_free_revoked_stateid() is
> safe in calling nfs4_test_and_free_stateid() because it is bypassing
> the
> TEST_STATEID by setting stateid->type = NFS4_REVOKED_STATEID_TYPE.
> 
> > So, my question is why would we need to change
> > nfs4_delegreturn_done at
> > all? It should already be sending a FREE_STATEID when the server
> > returns NFS4ERR_EXPIRED or NFS4ERR_DELEG_REVOKED thanks to the call
> > to
> > nfs4_free_revoked_stateid().
> > 
> > If the server is returning anything other than those 2 errors for a
> > stateid that is pending a FREE_STATEID from the client, then that
> > server is broken.
> 
> My intent (with the BAD/STALE_STATEID part at least)
> was to fail safe even in the presence of a broken server.

I don't see how that would be useful. If the server is so broken that
it is returning NFS4ERR_BAD_STATEID in a situation where it expects the
client to send a FREE_STATEID, then it can't be trusted to do the right
thing for calls to TEST_STATEID either.

IOW: This isn't a fixable situation on the client.

> As to the other bit, the hypothesis is a bad response to PUTFH. (I
> cannot prove that I or others have seen this, BTW)
> 
> What is the appropriate client/server response(s) if the delegation
> is
> revoked and the PUTFH fails? The server should send the error on the
> PUTFH before evaluating the DELEGRETURN, correct?
> 

You're talking about the case where PUTFH returns NFS4ERR_STALE? Why
should the client be required free state for a file that has been
removed? There is nothing in RFC5661 that says that it has to, and it
wouldn't make any sense to impose such a requirement either. Once the
filehandle is stale, any locks protecting the file contents are a moot
point.

-- 
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trond.myklebust@hammerspace.com
