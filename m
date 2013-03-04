Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:58316 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758097Ab3CDOkF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2013 09:40:05 -0500
MIME-Version: 1.0
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9286AD113@sacexcmbx05-prd.hq.netapp.com>
References: <CACVXFVMKN6aeCvJcn7dyuonJYJDfYxWeW5KE6gfKRKJKFj2M4A@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9286AD113@sacexcmbx05-prd.hq.netapp.com>
Date: Mon, 4 Mar 2013 22:40:02 +0800
Message-ID: <CACVXFVM5VhU_ZgYr1KxERY7DXxMQpkWoiTyjyar91Hz=vU4-ug@mail.gmail.com>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
From: Ming Lei <ming.lei@canonical.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 4, 2013 at 10:14 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Mon, 2013-03-04 at 21:57 +0800, Ming Lei wrote:
>> Hi,
>>
>> The below warning can be triggered each time when mount.nfs is
>> running on 3.9-rc1.
>>
>> Not sure if freezable_schedule() inside rpc_wait_bit_killable should
>> be changed to schedule() since nfs_clid_init_mutex is held in the path.
>
> Cc:ing Jeff, who added freezable_schedule(), and applied it to
> rpc_wait_bit_killable.
>
> So this is occurring when the kernel enters the freeze state?

No, but the situation can really be triggered in freeze case, so
lockdep forecasts the problem correctly, :-)

> Why does it occur only with nfs_clid_init_mutex, and not with all the
> other mutexes that we hold across RPC calls? We hold inode->i_mutex
> across RPC calls all the time when doing renames, unlinks, file
> creation,...

At least in the mount.nfs context, only nfs_clid_init_mutex is held.

IMO, if locks might be held in the path, it isn't wise to call
freezable_schedule
inside rpc_wait_bit_killable().

Thanks,
--
Ming Lei
