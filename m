Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:40348 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1753540AbdJaUhy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Oct 2017 16:37:54 -0400
From: Andrew W Elble <aweits@rit.edu>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: deal with revoked delegations appropriately
References: <20171031192238.6906-1-aweits@rit.edu>
        <1509480724.45082.0.camel@primarydata.com>
Date: Tue, 31 Oct 2017 16:37:53 -0400
In-Reply-To: <1509480724.45082.0.camel@primarydata.com> (Trond Myklebust's
        message of "Tue, 31 Oct 2017 20:12:06 +0000")
Message-ID: <m2zi87rr32.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond Myklebust <trondmy@primarydata.com> writes:

> On Tue, 2017-10-31 at 15:22 -0400, Andrew Elble wrote:
>> If a delegation has been revoked by the server, operations using that
>> delegation should error out with NFS4ERR_DELEG_REVOKED in the >4.1
>> case, and NFS4ERR_BAD_STATEID otherwise. DELEGRETURN has also been
>> optimized to return NFS4_OK when called with a revoked delegation.
>> 
>> Thread on DELEGRETURN optimization is here:
>> https://www.spinics.net/lists/linux-nfs/msg55216.html
>> 
>> Signed-off-by: Andrew Elble <aweits@rit.edu>
>> 
> Please see the patch series for knfsd that I posted yesterday. Does
> that fix your issue?

Just about to start looking at that in-depth, but I don't think so unless somehow
the typemask is changed to actually return revoked stateids? The problem
is we're not looking for revoked stateids in typemask for
nfsd4_lookup_stateid(), and they're not returned by default.

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
