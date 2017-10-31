Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:52844 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1754100AbdJaWdm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Oct 2017 18:33:42 -0400
From: Andrew W Elble <aweits@rit.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/5] nfsd: Fix stateid races between OPEN and CLOSE
References: <20171031000951.18294-1-trond.myklebust@primarydata.com>
        <20171031000951.18294-2-trond.myklebust@primarydata.com>
Date: Tue, 31 Oct 2017 18:33:41 -0400
In-Reply-To: <20171031000951.18294-2-trond.myklebust@primarydata.com> (Trond
        Myklebust's message of "Mon, 30 Oct 2017 20:09:47 -0400")
Message-ID: <m2vaivrlq2.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Not directly related to this patch series, but:

I keep staring at the failure path in nfsd4_process_open2() from the
call to nfs4_get_vfs_file() and thinking that there's a missing state
change to the stateid that's still hashed before the mutex is dropped
and the call to release_open_stateid()?

Thanks,

Andy

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
