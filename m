Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:49197 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1727733AbeJEWYv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Oct 2018 18:24:51 -0400
From: Andrew W Elble <aweits@rit.edu>
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] nfs: make DELEGRETURN try harder to determine if a delegation has been revoked
References: <20181005133429.79332-1-aweits@rit.edu>
        <04588fc1ef331c111185cb2f940d20a2e183e598.camel@hammerspace.com>
        <8b5d00b03e9a2fc20ebb3c6e3e040f3225beed22.camel@hammerspace.com>
Date: Fri, 05 Oct 2018 11:25:40 -0400
In-Reply-To: <8b5d00b03e9a2fc20ebb3c6e3e040f3225beed22.camel@hammerspace.com>
        (Trond Myklebust's message of "Fri, 5 Oct 2018 14:05:09 +0000")
Message-ID: <m2sh1kbekr.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>> NACK. We don't ever want to run synchronous RPC calls from inside an
>> rpciod context. There be deadlocks...

ahhh yes, I missed the fact that nfs4_free_revoked_stateid() is
safe in calling nfs4_test_and_free_stateid() because it is bypassing the
TEST_STATEID by setting stateid->type = NFS4_REVOKED_STATEID_TYPE.

> So, my question is why would we need to change nfs4_delegreturn_done at
> all? It should already be sending a FREE_STATEID when the server
> returns NFS4ERR_EXPIRED or NFS4ERR_DELEG_REVOKED thanks to the call to
> nfs4_free_revoked_stateid().
>
> If the server is returning anything other than those 2 errors for a
> stateid that is pending a FREE_STATEID from the client, then that
> server is broken.

My intent (with the BAD/STALE_STATEID part at least)
was to fail safe even in the presence of a broken server.

As to the other bit, the hypothesis is a bad response to PUTFH. (I
cannot prove that I or others have seen this, BTW)

What is the appropriate client/server response(s) if the delegation is
revoked and the PUTFH fails? The server should send the error on the
PUTFH before evaluating the DELEGRETURN, correct?

Thanks,

Andy

-- 
Andrew W. Elble
Infrastructure Engineer
Information and Technology Services
Rochester Institute of Technology
tel: (585)-475-2411 | aweits@rit.edu
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
