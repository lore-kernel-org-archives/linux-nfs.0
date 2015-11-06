Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:63732 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932824AbbKFNIV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Nov 2015 08:08:21 -0500
From: Andrew W Elble <aweits@rit.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bruce James Fields <bfields@fieldses.org>,
        Jeffrey Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH] nfsd: fix nfsd4_delegreturn to return correct error codes
References: <1446674837-4980-1-git-send-email-aweits@rit.edu>
	<CAHQdGtShZ=6J9h1hW00zPZ+TWzAYmfSiET-1mEdv1-H=JGEgcA@mail.gmail.com>
Date: Fri, 06 Nov 2015 08:08:20 -0500
In-Reply-To: <CAHQdGtShZ=6J9h1hW00zPZ+TWzAYmfSiET-1mEdv1-H=JGEgcA@mail.gmail.com>
	(Trond Myklebust's message of "Thu, 5 Nov 2015 17:31:37 -0500")
Message-ID: <m2mvurnum3.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> Umm... If the client is sending delegreturn, then why not destroy the
> delegation?

ObDisclaimer: My "internal" version of this patch does just that.

If the DELEGRETURN is the first time that the client hears of the
revocation, I'm guessing that there isn't anything that can be done to
rewind time and do anything differently. But as Bruce points out, it
seems like there are other places where NFS4ERR_DELEG_REVOKED should be
being returned.

> What is the point of forcing the client to send
> FREE_STATEID, when it is telling you that it is no longer caching any
> locks or associated state and is no longer interested in keeping the
> delegation?

But - I keep re-reading RFC5661, and I can't figure out how this is
what was intended.

It seems like the "correct" thing to do is inform the client (via probably
too many different methods) that the/a delegation is revoked and let it
acknowledge via FREE_STATEID. The allowed error returns in 15.2 seem to
confirm this view.

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
