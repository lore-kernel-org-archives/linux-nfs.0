Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:14855 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S932608AbdJaXpG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Oct 2017 19:45:06 -0400
From: Andrew W Elble <aweits@rit.edu>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/5] nfsd: Fix stateid races between OPEN and CLOSE
References: <20171031000951.18294-1-trond.myklebust@primarydata.com>
        <20171031000951.18294-2-trond.myklebust@primarydata.com>
        <m2vaivrlq2.fsf@discipline.rit.edu>
        <1509492271.3397.8.camel@primarydata.com>
Date: Tue, 31 Oct 2017 19:45:06 -0400
In-Reply-To: <1509492271.3397.8.camel@primarydata.com> (Trond Myklebust's
        message of "Tue, 31 Oct 2017 23:24:33 +0000")
Message-ID: <m2r2tiswzh.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <trondmy@primarydata.com> writes:

> On Tue, 2017-10-31 at 18:33 -0400, Andrew W Elble wrote:
>> Not directly related to this patch series, but:
>> 
>> I keep staring at the failure path in nfsd4_process_open2() from the
>> call to nfs4_get_vfs_file() and thinking that there's a missing state
>> change to the stateid that's still hashed before the mutex is dropped
>> and the call to release_open_stateid()?
>> 
>
> If the seqid==1, so that we know this OPEN op created that stateid,
> then it probably should be unhashed and marked as closed, since then we
> know it represents no state. Otherwise, AFAICS it should keep its
> current state + seqid.
>
> Do you want to send a patch, or should I update this patch series? Such
> a fix probably does want to be a stable patch, since it will affect
> clients that expect compliance with RFC5661/RFC7530.

Please feel free to go ahead and update this series.

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
