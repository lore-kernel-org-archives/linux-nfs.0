Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:51039 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1751831AbdKFRaY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Nov 2017 12:30:24 -0500
From: Andrew W Elble <aweits@rit.edu>
To: "bfields@fieldses.org" <bfields@fieldses.org>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] nfsd: deal with revoked delegations appropriately
References: <20171103180631.76071-1-aweits@rit.edu>
        <1509734212.21477.16.camel@primarydata.com>
        <20171106151531.GB599@fieldses.org>
Date: Mon, 06 Nov 2017 12:30:23 -0500
In-Reply-To: <20171106151531.GB599@fieldses.org> (bfields@fieldses.org's
        message of "Mon, 6 Nov 2017 10:15:31 -0500")
Message-ID: <m2fu9rqpqo.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


"bfields@fieldses.org" <bfields@fieldses.org> writes:

> On Fri, Nov 03, 2017 at 06:36:55PM +0000, Trond Myklebust wrote:
>> Thanks for the quick turnaround!
>> 
>> On Fri, 2017-11-03 at 14:06 -0400, Andrew Elble wrote:
>> > If a delegation has been revoked by the server, operations using that
>> > delegation should error out with NFS4ERR_DELEG_REVOKED in the >4.1
>> > case, and NFS4ERR_BAD_STATEID otherwise.
>> > 
>> > Signed-off-by: Andrew Elble <aweits@rit.edu>
>> 
>> Reviewed-by: Trond Myklebust <trond.myklebust@primarydata.com>
>
> I wonder if there's a way to simplify the resulting logic in
> nfsd4_lookup_stateid--I guess I don't see anything.
>
> Could we get some context here in the changelog, though?  What actual
> problem was this causing?

Prior thread (roughly) here: http://www.spinics.net/lists/linux-nfs/msg55260.html

This is the one patch I'm still carrying from the lost delegation work a
while back. Testing showed that there is a path still open to lost
delegations via delegreturn.

running with:
echo "error != 0" | sudo tee /sys/kernel/debug/tracing/events/nfs4/nfs4_delegreturn_exit/filter

gave us this at one point with an interim version of this patch:

kworker/0:0H-3990  [000] .... 5899655.609266: nfs4_delegreturn_exit: 
               error=-10087 (DELEG_REVOKED) dev=00:30 fhandle=0xe43d9d3a
kworker/0:2H-12665 [000] .... 5900011.719468: nfs4_delegreturn_exit: 
               error=-10087 (DELEG_REVOKED) dev=00:30 fhandle=0x16e37c0a

The Linux client prior to 26d36301bd653df6481fd38f3e1435a1f15e56d1 would
just drop delegations that suffered from a nfserr_bad_stateid during
delegreturn. Now it will do test/free if the return error is
nfserr_deleg_revoked.

If the client drops a delegation while the server has it on the revoked
list, we stay stuck in endless state manager looping for that client.

It might be a good idea for a stable backport of aforementioned commit,
or some kind of other workaround? Possibly interpreting
nfserr_bad_stateid an analogue of nfserr_deleg_revoked clientside
when dealing with a >4.0 mount? (also seems like an error on the putfh
might need to be caught as well?)

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
