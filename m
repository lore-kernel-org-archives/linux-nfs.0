Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:38598 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755174AbbGCVKE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jul 2015 17:10:04 -0400
Received: by igrv9 with SMTP id v9so83529367igr.1
        for <linux-nfs@vger.kernel.org>; Fri, 03 Jul 2015 14:10:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSkQmk7_z4ckXvefONjUQu6DVxui_q66RYdq-Tc7D_GKQ@mail.gmail.com>
References: <1435877253-1497-1-git-send-email-mchen@cs.stonybrook.edu>
	<CAHQdGtSkQmk7_z4ckXvefONjUQu6DVxui_q66RYdq-Tc7D_GKQ@mail.gmail.com>
Date: Fri, 3 Jul 2015 17:10:03 -0400
Message-ID: <CAGDv-a7Z9JWw+fw50tjm887Y8s16O8xFXBvhbPdFVV0qYCADXg@mail.gmail.com>
Subject: Re: [PATCH] nfs: avoid nfs_wait_on_seqid() for NFSv4.1
From: Ming Chen <mchen@cs.stonybrook.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        ezk@fsl.cs.stonybrook.edu
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Glad that this is fixed. I just verified that in vanilla 4.1.1,
NFSv4.1 is performing well with parallel opens. We found this problem
in our benchmarking study using 3.14.17. In case you are interested,
we wrote a paper about NFSv4.1 benchmarking:
http://www.fsl.cs.sunysb.edu/docs/nfs4perf/nfs4perf-sigm15.pdf

Thanks,
Ming

On Thu, Jul 2, 2015 at 7:23 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Thu, Jul 2, 2015 at 6:47 PM, Ming Chen <mchen@cs.stonybrook.edu> wrote:
>>
>> seqid, introduced in NFSv4.0, requires state-changing operations be performed
>> synchronously, and thus limits parallelism. NFSv4.1 supports "unlimited
>> parallelism" by using sessions and slots; seqid is no longer used and must be
>> ignored by NFSv4.1 server. However, the current nfs client always call
>> nfs_wait_on_seqid() no matter the version is 4.0 or 4.1.
>
> Please see commit 63f5f796af613 ("NFSv4.1: Allow parallel
> OPEN/OPEN_DOWNGRADE/CLOSE") which first appeared in Linux-4.0.
>
> Cheers
>   Trond
