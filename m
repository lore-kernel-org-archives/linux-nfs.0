Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f182.google.com ([209.85.212.182]:52636 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763AbaKYO05 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2014 09:26:57 -0500
Received: by mail-wi0-f182.google.com with SMTP id h11so1633813wiw.3
        for <linux-nfs@vger.kernel.org>; Tue, 25 Nov 2014 06:26:56 -0800 (PST)
Message-ID: <547491AD.5090909@gmail.com>
Date: Tue, 25 Nov 2014 15:26:53 +0100
From: poma <pomidorabelisima@gmail.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: Josh Boyer <jwboyer@fedoraproject.org>, Paul Bolle <pebolle@tiscali.nl>,
        Ian Chapman <packages@amiga-hardware.com>,
        "Justin M. Forbes" <jforbes@redhat.com>,
        Community support for Fedora users
	<users@lists.fedoraproject.org>,
        Mailing-List fedora-kernel <kernel@lists.fedoraproject.org>,
        Tom Tucker <tom@opengridcomputing.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: NFS over RMDA
References: <5474567D.6070609@amiga-hardware.com> <547478A7.8050606@gmail.com> <1416921128.10073.53.camel@x220> <20141125132947.GA18909@hansolo.jdub.homelinux.org>
In-Reply-To: <20141125132947.GA18909@hansolo.jdub.homelinux.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 25.11.2014 14:29, Josh Boyer wrote:
> On Tue, Nov 25, 2014 at 02:12:08PM +0100, Paul Bolle wrote:
>> On Tue, 2014-11-25 at 13:40 +0100, poma wrote:
>>> On 25.11.2014 11:14, Ian Chapman wrote:
>>>> Hi,
>>>>
>>>> Is anyone successfully running NFS over RDMA on Fedora 20+?
>>>>
>>>> I've edited /etc/sysconfig/nfs and set the the following config paramter.
>>>>
>>>> RDMA_PORT=20049
>>>>
>>>> Upon restarting the nfs server I get the following:
>>>>
>>>> modprobe: FATAL: Module svcrdma not found
>>>> /usr/libexec/nfs-utils/scripts/nfs-server.postconfig: line 12: echo: 
>>>> write error: Protocol not supported
>>>>
>>>> So it looks like the kernel module svcrdma is missing and the last 
>>>> kernel to have it was 3.11.10-301.fc20. The postconfig script belongs to 
>>>> nfs-utils.
>>>>
>>>> Is svcrdma intentionally not built in the current kernels or has it been 
>>>> replaced by something else?
>>>>
>>>
>>> [snip unedited copy from someone's terminal]
>>
>> 0) In mainline kernel v3.15 the config option SUNRPC_XPRT_RDMA was split
>> in two options: SUNRPC_XPRT_RDMA_CLIENT and SUNRPC_XPRT_RDMA_SERVER. See
>> commit 2e8c12e1b765 ("xprtrdma: add separate Kconfig options for
>> NFSoRDMA client and server support").
>>
>> 1) Fedora 20 first shipped v3.15 in last July (kernel-3.15.3-200.fc20).
>> Looking at the git history of the Fedora kernel package I found commit
>> commit fd469c7db4e6 ("Linux v3.15.2"). It dropped
>> CONFIG_SUNRPC_XPRT_RDMA=m from the config files (as it was useless). It
>> set CONFIG_SUNRPC_XPRT_RDMA_CLIENT to 'm' but did not set
>> CONFIG_SUNRPC_XPRT_RDMA_SERVER. The commit offers no explanation of this
>> choice. Perhaps it was discusses somewhere else.
>>
>> 2) A similar commit for Rawhide was 700baa35a69e ("Linux
>> v3.14-12042-g69cd9eba3886"), but it doesn't comment on this choice
>> either.
>>
>> 3) Perhaps Justin or Josh, authors of those commits, might recall why
>> only CONFIG_SUNRPC_XPRT_RDMA_CLIENT was set.
> 
> At the time, server support for NFSoRDMA wasn't in the greatest shape
> and we disabled it at the request of the NFS developers.  I believe this
> also matches what wound up in RHEL7.
> 
> The NFS developers haven't asked us to turn it back on, so it has stayed
> off since.
> 
> josh
> 

Chuck, what is the current recommendation for 'CONFIG_SUNRPC_XPRT_RDMA_SERVER'?


poma


