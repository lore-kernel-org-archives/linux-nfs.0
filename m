Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23784 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757450AbbIUX2V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2015 19:28:21 -0400
Subject: Re: [PATCH v1 00/24] New fast registration API
To: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Sagi Grimberg <sagig@mellanox.com>, linux-rdma@vger.kernel.org
References: <1442482947-27785-1-git-send-email-sagig@mellanox.com>
 <55FDEDD5.1090105@oracle.com> <55FE7E24.20300@dev.mellanox.co.il>
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Message-ID: <5600928A.7070202@oracle.com>
Date: Mon, 21 Sep 2015 16:28:10 -0700
MIME-Version: 1.0
In-Reply-To: <55FE7E24.20300@dev.mellanox.co.il>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Sagi,

On 9/20/15 2:36 AM, Sagi Grimberg wrote:
> Hi Santosh,
>
>> Nice to see this consolidaton happening. I too don't have access to
>> iWARP hardware for RDS test but will use this series and convert our WIP
>> IB fastreg code and see how it goes.
>
> I'm very pleased to hear about this WIP. Please feel free to share
> anything you have (code and questions/dilemmas) with the list. Also, if
> you have more suggestions on how we can do better from your PoV we'd
> love to hear about it.
>
So as promised, I tried to test your series.  Your github branch [1]
'reg_api.3' though mostly has 4.3-rc1 contents, it isn't
based of 4.3-rc1 so I just cherry picked the patches and created
'rdma/sagi/reg_api.3_cherrypick' [2]. I had conflict with iser
patch so I just dropped that one.

As mentioned earlier, I have a WIP RDS fastreg branch [3]
which is functional (at least I can RDMA messages across
nodes ;-)). So merging [2] and [3], I created [4] and applied
a delta change based on your other patches. I saw ib_post_send
failure with my HCA driver returning '-EINVAL'. I didn't
debug it further but at least opcode and num_sge were set
correctly so I shouldn't have seen it. So I did memset()
on reg_wr which seems to have helped to fix the ib_post_send()
failure.

But I got into remote access errors which tells me that I
have messed up setup(rkey, sge setup or access flags)
or missing some other patch(s) in my test tree[4]. Delta
patch is top commit on [4].

Please let me know if you spot something which I missed.

Regards,
Santosh

[1] https://github.com/sagigrimberg/linux/tree/reg_api.3
[2] 
https://git.kernel.org/cgit/linux/kernel/git/ssantosh/linux.git/log/?h=rdma/sagi/reg_api.3_cherrypick
[3] 
https://git.kernel.org/cgit/linux/kernel/git/ssantosh/linux.git/log/?h=net/rds/4.3-fr-wip
[4]https://git.kernel.org/cgit/linux/kernel/git/ssantosh/linux.git/commit/?h=test/reg_api.3/rds
