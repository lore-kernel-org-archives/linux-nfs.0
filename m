Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:22343 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1161614AbbKEPT3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2015 10:19:29 -0500
From: Andrew W Elble <aweits@rit.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC v3] nfs: nfs_do_return_delegation() needs to send FREE_STATEID
References: <1446684228-37765-1-git-send-email-aweits@rit.edu>
	<CAHQdGtQmYV9Aq+=CivbmPTjHMZVhd8BznpMsmXXD=cZwzOO0Uw@mail.gmail.com>
Date: Thu, 05 Nov 2015 10:19:27 -0500
In-Reply-To: <CAHQdGtQmYV9Aq+=CivbmPTjHMZVhd8BznpMsmXXD=cZwzOO0Uw@mail.gmail.com>
	(Trond Myklebust's message of "Thu, 5 Nov 2015 09:27:06 -0500")
Message-ID: <m2twp0v5hc.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> If the server is revoking a delegation, then presumably it will also
> set one or more of the SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED,
> SEQ4_STATUS_ADMIN_STATE_REVOKED, SEQ4_STATUS_RECALLABLE_STATE_REVOKED,
> which should start up a state manager thread to do the
> test_stateid/free_stateid dance.
>
> So instead of adding the free stateid call above, why can't we just
> punt the freeing of the delegation to the state manager?

I inferred (perhaps incorrectly) that nfs_do_return_delegation() was a
place delegations went to and didn't come back from.

I managed to convince myself that since all callers of
nfs_do_return_delegation() detach the delegation, the state manager
wouldn't be able to perform that function without reattaching the
delegation - and that doesn't look quite so safe (and/or possible)
in all of those call paths?

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
