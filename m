Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:49261
        "EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751121AbdCQSO2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Mar 2017 14:14:28 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Olga Kornievskaia'" <aglo@umich.edu>,
        "'linux-nfs'" <linux-nfs@vger.kernel.org>
References: <CAN-5tyH433qTV9EY5MQpDhRhgekUv7e=R1H7N_Q_46cAwPO=eg@mail.gmail.com>
In-Reply-To: <CAN-5tyH433qTV9EY5MQpDhRhgekUv7e=R1H7N_Q_46cAwPO=eg@mail.gmail.com>
Subject: RE: question about open_owner sequencing
Date: Fri, 17 Mar 2017 10:45:38 -0700
Message-ID: <055901d29f46$4adcb0f0$e09612d0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 Hi folks,
> 
> I have a question about recovery from the BAD_SEQID and what should
> happen.
> 
> I have the following application that does:
> 
> 1. open(file1)
> 2. open(file2)
> 3. close(file1)
> 4. open(file3)
> 5. lock(file2)
> 
> If CLOSE gets BAD_SEQID (for whatever reason), I see that LOCK later fails
> with BAD_SEQID as well.
> 
> step1 OPEN creates open_owner1 seq 0
> step2 OPEN uses open_owner1 seq1
> step3 CLOSE uses open_owner1 seq2 gets BAD_SEQID
> step4 OPEN sends new open_owner2 seq2 and it triggers OPEN_CONFIRM
> with seq3
> step5 sends LOCK with seq4 and open stateid from the reply in step 2.
> 
> LOCK gets BAD_SEQID.
> 
> Question: is client sending something incorrect? is server not correct? I
> tested against two different servers (Linux and NetApp) and both reply the
> same way so I'm leaning towards "no". But I don't see why "seq4" is not a
> valid sequence given that the open_owner/sequence was just confirmed.

Wait step4 is using a new open owner? Each open owner has its own seqid (assuming this is V4.0, owner seqid doesn't apply to 4.1 since the sequencing is done for the session with the SEQUENCE op).

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

