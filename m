Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl0-f42.google.com ([209.85.160.42]:38816 "EHLO
        mail-pl0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751393AbeE3Krh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 06:47:37 -0400
Received: by mail-pl0-f42.google.com with SMTP id c11-v6so10861344plr.5
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 03:47:36 -0700 (PDT)
Subject: Re: question: re-try of operations in PNFS
To: Olga Kornievskaia <aglo@umich.edu>,
        "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
References: <CAN-5tyH2OVzr5TTN_sCrKxEiXaDiPzh=8zykR__jq=k2ve5Vaw@mail.gmail.com>
 <955655871.7566389.1527021265316.JavaMail.zimbra@desy.de>
 <CAN-5tyE4gO9=pDtSPC+vbH4HuBs69Qyt8tSPFMM6_cg32BrH9A@mail.gmail.com>
From: Suresh Jayaraman <suresh.jayaraman@tegile.com>
Message-ID: <09ccda5b-d59b-1996-12db-a0d5b38a985a@tegile.com>
Date: Wed, 30 May 2018 16:17:27 +0530
MIME-Version: 1.0
In-Reply-To: <CAN-5tyE4gO9=pDtSPC+vbH4HuBs69Qyt8tSPFMM6_cg32BrH9A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/23/2018 02:15 AM, Olga Kornievskaia wrote:
>> we saw similar issues with early version of RHEL6 kernels, but this was fixed in the later version.
>> and it's possible now to set timeout with
>>
>> dataserver_timeo and dataserver_retrans
>>
>> bugzilla: https://bugzilla.redhat.com/show_bug.cgi?id=1175413
>>
>> Which which kernel do you observe it?
> 
> Upstream kernel. But I'm arguing that there shouldn't be a need to
> specify a dataserver_timeo because it shouldn't timeout at all just
> like MDS operations.
> 
> Also curiously, "man nfs" doesn't list "datasever_timeo" option and
> when I try to use it on a RHEL7.4 machine it says incorrect option.
> Also grep thru the upstream kernel code for "dataserver_timeo" is
> empty too.
> 

I still see these options (as module parameters to 
nfs_layout_nfsv41_files module) in the mainline kernel (4.17-rc7).

We are facing the problem with IO being routed through MDS when DS is 
momentarily unavailable (for e.g. DS restart or DS failover). Wondering 
if anyone found this timeout helpful in the case when the network 
connection goes down as part of DS failover for instance. In the past, 
we had observed that the IO is being routed through MDS immediately 
after DS is restarted and MDS won't be in a position to complete the IO.


Regards,
Suresh
