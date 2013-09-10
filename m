Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:45471 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047Ab3IJVIw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Sep 2013 17:08:52 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Dros" <Weston.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFSv4.1: clean up after using machine cred
Date: Tue, 10 Sep 2013 21:08:31 +0000
Message-ID: <99A4AB2C-5C44-4F9D-8D7A-4601AC07DCB0@netapp.com>
References: <1378839358-10389-1-git-send-email-dros@netapp.com>
 <1378839358-10389-2-git-send-email-dros@netapp.com>
 <1378841499.21916.22.camel@leira.trondhjem.org>
In-Reply-To: <1378841499.21916.22.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yes, I thought about this approach, but backed away since we do get/put_rpccred on the cl_machine_cred elsewhere (like nfs4_get_machine_cred_locked).

Shall I submit a new patch that gets rid of get/put_rpccred?

Do we also want to change other uses of cl_machine_cred?

Thanks,
-dros

On Sep 10, 2013, at 3:31 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
 wrote:

> On Tue, 2013-09-10 at 14:55 -0400, Weston Andros Adamson wrote:
>> Client calls get_rpccred when referencing the machine cred, so it must call
>> put_rpccred after passing cred to rpc layer.
>> 
>> This patch also moves nfs4_sp4_init (formerly nfs4_state_protect) to right
>> before the call to rpc_run_task (and wrappers of rpc_run_task) to minimize
>> error path cleanup code.
>> 
> 
> Do we really need this? AFAICS once the clp->cl_machine_cred is set, it
> isn't freed until the call to nfs_free_client(). In fact, we probably
> _rely_ on this being the case for SP4_MACH_CRED, since if the machine
> cred were to change, we'd no longer be able to change our session or
> lease.
> 
> IOW: instead of referencing the cred via get/put_rpccred(), maybe we can
> just feed the current value of clp->cl_machine_cred into the
> msg->rpc_cred.
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

