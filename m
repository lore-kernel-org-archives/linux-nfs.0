Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:48085 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756090Ab1G1Wbv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 18:31:51 -0400
Message-ID: <4E31E336.9090702@panasas.com>
Date: Thu, 28 Jul 2011 15:31:18 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Gregory Magoon <gmagoon@MIT.EDU>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 vs NFSv3 with MPICH2-1.4
References: <20110728152306.219iz5wpkcokoo4c@webmail.mit.edu> <1311886684.27285.8.camel@lade.trondhjem.org> <20110728172449.8wxxte4jg0s8kcgs@webmail.mit.edu> <1311889677.27285.14.camel@lade.trondhjem.org> <20110728180120.bf6gq5zyos8wwg4s@webmail.mit.edu>
In-Reply-To: <20110728180120.bf6gq5zyos8wwg4s@webmail.mit.edu>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/28/2011 03:01 PM, Gregory Magoon wrote:
> I'll try this the next time I get a chance.
> 
> Just to be clear, I don't think it is a performance issue; I think it is just
> getting stuck.
> 
> Greg
> 
> Quoting Trond Myklebust <Trond.Myklebust@netapp.com>:
> 
> 
>> Have you turned off delegations on the server? I wouldn't expect them to
>> help much on an MPI workload.
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi Gregory

We are using MPICH2-1.3.1 and the IOR mpich test. as well as the mdtest
test. And have had no issues so far with nfsv4 nfsv4.1 and pnfs. In fact
this is our standard performance test. 

What tests are you using? 
Do you know of any major changes between MPICH2-1.3.1 and MPICH2-1.4? 
Also are you using the builtin nfs-client driver or the POSIX interface?

Boaz
