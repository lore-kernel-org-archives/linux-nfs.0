Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:35399 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964903AbbKFNsj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Nov 2015 08:48:39 -0500
Received: by oige206 with SMTP id e206so12264317oig.2
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2015 05:48:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <m2mvurnum3.fsf@discipline.rit.edu>
References: <1446674837-4980-1-git-send-email-aweits@rit.edu>
	<CAHQdGtShZ=6J9h1hW00zPZ+TWzAYmfSiET-1mEdv1-H=JGEgcA@mail.gmail.com>
	<m2mvurnum3.fsf@discipline.rit.edu>
Date: Fri, 6 Nov 2015 08:48:36 -0500
Message-ID: <CAHQdGtSbxKDHSD+kxv5Fa6CLoSrB3KjeRjyTsNDhR47VYCUgOg@mail.gmail.com>
Subject: Re: [PATCH] nfsd: fix nfsd4_delegreturn to return correct error codes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andrew W Elble <aweits@rit.edu>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bruce James Fields <bfields@fieldses.org>,
        Jeffrey Layton <jlayton@poochiereds.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 6, 2015 at 8:08 AM, Andrew W Elble <aweits@rit.edu> wrote:
>
>> Umm... If the client is sending delegreturn, then why not destroy the
>> delegation?
>
> ObDisclaimer: My "internal" version of this patch does just that.
>
> If the DELEGRETURN is the first time that the client hears of the
> revocation, I'm guessing that there isn't anything that can be done to
> rewind time and do anything differently. But as Bruce points out, it
> seems like there are other places where NFS4ERR_DELEG_REVOKED should be
> being returned.
>
>> What is the point of forcing the client to send
>> FREE_STATEID, when it is telling you that it is no longer caching any
>> locks or associated state and is no longer interested in keeping the
>> delegation?
>
> But - I keep re-reading RFC5661, and I can't figure out how this is
> what was intended.
>
> It seems like the "correct" thing to do is inform the client (via probably
> too many different methods) that the/a delegation is revoked and let it
> acknowledge via FREE_STATEID. The allowed error returns in 15.2 seem to
> confirm this view.

Just because the protocol _allows_ you to do this, it doesn't mean
that it is the right thing to do.
Section 8.2.4. reads:

   Stateids must remain valid until either a client restart or a server
   restart or until the client returns all of the locks associated with
   the stateid by means of an operation such as CLOSE or DELEGRETURN.
   If the locks are lost due to revocation, as long as the client ID is
   valid, the stateid remains a valid designation of that revoked state
   until the client frees it by using FREE_STATEID.

In this case, there are no lost locks due to revocation.

The client has presumably not received NFS4ERR_DELEG_REVOKED on any of
its previous uses of the delegation stateid and it has presumably not
seen any SEQ4_STATUS_* notifications when recovering locks, since both
of those situations should cause the client to switch to using
TEST_STATEID/FREE_STATEID instead of a DELEGRETURN.

So, what exactly is the client supposed to do differently when the
server replies NFS4ERR_DELEG_REVOKED to the DELEGRETURN other than
send a completely redundant FREE_STATEID? Why couldn't the server just
return NFS4ERR_OK?
