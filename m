Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:36694 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1750928AbdKFVZT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Nov 2017 16:25:19 -0500
From: Andrew W Elble <aweits@rit.edu>
To: "bfields@fieldses.org" <bfields@fieldses.org>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] nfsd: deal with revoked delegations appropriately
References: <20171103180631.76071-1-aweits@rit.edu>
        <1509734212.21477.16.camel@primarydata.com>
        <20171106151531.GB599@fieldses.org>
        <m2fu9rqpqo.fsf@discipline.rit.edu>
        <20171106193528.GA13456@fieldses.org>
Date: Mon, 06 Nov 2017 16:25:19 -0500
In-Reply-To: <20171106193528.GA13456@fieldses.org> (bfields@fieldses.org's
        message of "Mon, 6 Nov 2017 14:35:28 -0500")
Message-ID: <m24lq7qev4.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


"bfields@fieldses.org" <bfields@fieldses.org> writes:

> I'm just looking for a concise explanation of why your patch is
> important.  And I probably haven't dug enough, but I'm still not quite
> following.
>
> If I understand right, the only visible change from your patch will be
> returning DELEG_REVOKED instead of BAD_STATEID to 4.1 clients in some
> cases.  I'm not clear what the result was (for old or new clients)--a
> client left believing it held a delegation when it didn't, or a client
> entering an infinite state manager loop?

The current Linux client will "lose" a delegation on DELEGRETURN if it
does not see NFS4ERR_DELEG_REVOKED. This is unrecoverable and will
result in the client state manager looping unable to satisfy the
server's inevitable assertion of SEQ4_STATUS_RECALLABLE_STATE_REVOKED.

RFC5661 10.2.1: "A client normally finds out about revocation of a delegation
when it uses a stateid associated with a delegation and receives one of
the errors NFS4ERR_EXPIRED, NFS4ERR_ADMIN_REVOKED, or NFS4ERR_DELEG_REVOKED."

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
