Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga07-in.huawei.com ([45.249.212.35]:59919 "EHLO huawei.com"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751475AbeEPKhc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 16 May 2018 06:37:32 -0400
Subject: Re: mounting NFS on the same host leads to D state
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        <jlayton@kernel.org>, <linux-nfs@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>
References: <737a947e-a53d-fcd2-bbc3-ca373bea6cb1@huawei.com>
CC: <yangerkun@huawei.com>, "weiyongjun (A)" <weiyongjun1@huawei.com>
From: maowenan <maowenan@huawei.com>
Message-ID: <19ceda78-8419-baee-2cdb-c2a02562e7db@huawei.com>
Date: Wed, 16 May 2018 18:37:15 +0800
MIME-Version: 1.0
In-Reply-To: <737a947e-a53d-fcd2-bbc3-ca373bea6cb1@huawei.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have tested in recent version 4.16 rc7 and find it also has the same issue.
@Eric do you have any comments about this nfs issue?

On 2018/5/15 11:47, maowenan wrote:
> Hi,
> 
> Recently I have tested NFS and exportfs scenario,
> that NFS server and client are in the same host.
> And I found mounting NFS filesystm onto the same host
> can lead to rpc.mountd and related task become D state.
> My kernel version is based on 3.10, and I find 4.15 has the same
> appearance.
> 
> My test step as below:
> 1)create dir.
> mkdir -p /home/test1 /home/test2
> 2)share dir /home/test1
> echo '/home/test1 localhost(rw,all_squash,anonuid=0,anongid=0)' > /etc/exports
> 3)exportfs
> exportfs -vr || echo "Failed to export /home/test1"
> 4)mount NFS.
> mount localhost:/home/test1 /home/test2 -o vers=3,soft
> 5)share dir /home/test2
> echo '/home/test2 *(rw,all_squash,anonuid=0,anongid=0)' >> /etc/exports
> 6)exportfs
> exportfs -vr
> 7) list /home/test2
> ls /home/test2
> then we found ls command is hung, ls and rpc.mountd became "D" state, and after
> 180 second ls command return.
> 
> Another scenario as below:
> 1)create dir.
> mkdir -p /home/test3 /home/test4
> 2)share dir /home/test3
> echo '/home/test3 localhost(rw,sync,no_wdelay,anonuid=0,anongid=0,no_subtree_check)' > /etc/exports
> 3)exportfs
> exportfs -r
> 4)to see NFS status
> showmount -e localhost
> 5)mount NFS
> mount -t nfs4 -o proto=tcp,nolock,soft,timeo=50 localhost:/home/test3 /home/test4
> 6) stop nfs service,and  and check ls task state is D.
> service nfs stop
> ls /home/test4
> ls command is hung and became D state.
> 
> I wonder to know is it reasonable about these test scenario because NFS server and
> client are in the same host? Since some task went into D state, is there any reason about this?
> and is there any patch to fix this issue?
> Here is a link to talk about NFS mounting on the same host,  https://lwn.net/Articles/595652/
> 

