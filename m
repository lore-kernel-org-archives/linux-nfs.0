Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga18.intel.com ([134.134.136.126]:35554 "EHLO mga18.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751810AbeBVCbo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Feb 2018 21:31:44 -0500
Date: Thu, 22 Feb 2018 10:31:40 +0800
From: Fengguang Wu <lkp@intel.com>
To: Philip Li <philip.li@intel.com>
Cc: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kbuild-all@01.org, Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [kbuild-all] [PATCH 19/23] NFS/NFSD/SUNRPC: replace generic
 creds with 'struct cred'.
Message-ID: <20180222023140.liuklv2qx3hvhett@wfg-t540p.sh.intel.com>
References: <151901654943.17421.16135174786512989263.stgit@noble>
 <201802192252.Y6fdV4Fk%fengguang.wu@intel.com>
 <87woz8jz0g.fsf@notabene.neil.brown.name>
 <20180222015123.GA14244@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
In-Reply-To: <20180222015123.GA14244@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 22, 2018 at 09:51:23AM +0800, Philip Li wrote:
>On Tue, Feb 20, 2018 at 11:17:03AM +1100, NeilBrown wrote:
>> On Mon, Feb 19 2018, kbuild test robot wrote:
>>
>> > Hi NeilBrown,
>> >
>> > Thank you for the patch! Perhaps something to improve:
>> >
>> > [auto build test WARNING on nfs/linux-next]
>> > [also build test WARNING on v4.16-rc2 next-20180219]
>> > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>> >
>> > url:    https://github.com/0day-ci/linux/commits/NeilBrown/Remove-generic-rpc-credentials-and-associated-changed-V3/20180219-190836
>> > base:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next
>> > reproduce:
>> >         # apt-get install sparse
>> >         make ARCH=x86_64 allmodconfig
>> >         make C=1 CF=-D__CHECK_ENDIAN__
>> >
>> >
>> > sparse warnings: (new ones prefixed by >>)
>> >
>> >>> fs/nfs/flexfilelayout/flexfilelayout.c:517:40: sparse: incorrect type in initializer (different address spaces) @@ expected struct cred const @@ got cred const @@
>> >    fs/nfs/flexfilelayout/flexfilelayout.c:517:40: expected struct cred const
>> >    fs/nfs/flexfilelayout/flexfilelayout.c:517:40: got struct cred const Documentation Kbuild Kconfig Makefile certs drivers firmware fs include samples scripts sound tools cred
>>
>> Hi Mr Robot :-)
>>  It looks like you have some strange wild-card expansion happening here.
>>  I think the above should be
>> >    fs/nfs/flexfilelayout/flexfilelayout.c:517:40: got struct cred const * cred
>thanks for pointing this out, we will fix it.

Obviously the robot shell-expands the '*' in error message ...

>>
>> Even after correcting the that, I cannot see what the different address
>> spaces are that might be a problem.
>> Does anyone have any ideas?
>>
>> Thanks,
>> NeilBrown
>
>
>
>> _______________________________________________
>> kbuild-all mailing list
>> kbuild-all@lists.01.org
>> https://lists.01.org/mailman/listinfo/kbuild-all
>
