Return-Path: <SRS0=mk5Y=RJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3172DC43381
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 16:01:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0BCC520675
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Mar 2019 16:01:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727320AbfCFQBi convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Mar 2019 11:01:38 -0500
Received: from mx1.redhat.com ([209.132.183.28]:37372 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727318AbfCFQBi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Mar 2019 11:01:38 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id BCA8C81E14;
        Wed,  6 Mar 2019 16:01:37 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-112-68.rdu2.redhat.com [10.10.112.68])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 258481001DF1;
        Wed,  6 Mar 2019 16:01:36 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     Kanika <jr.kanika@gmail.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: pnfs setup on Linux 4.15
Date:   Wed, 06 Mar 2019 11:01:35 -0500
Message-ID: <A469AE7A-B542-4BE7-BF1E-5EFD309DB0BB@redhat.com>
In-Reply-To: <CAP8UQm+gQZW5_FD5YMuh_fev0H7SAanwz92CpoA1Yyr7ooj7Hg@mail.gmail.com>
References: <CAP8UQm+od+oU63049_hgitTcBepCeG0vFBPHG90=WruVXGU_mw@mail.gmail.com>
 <CAP8UQm+gQZW5_FD5YMuh_fev0H7SAanwz92CpoA1Yyr7ooj7Hg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Content-Transfer-Encoding: 8BIT
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 06 Mar 2019 16:01:37 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi jrk,

The upstream linux knfsd server currently only supports a very simple 
flexfiles layout where the MDS and the DS are the same server, so 
there's no way (yet) to configure knfsd to give out flexfiles layouts 
that point to other DS servers.

See commit 9b9960a0ca4773e21c4b153ed355583946346b25 in the linux git 
repo for the work that implements this simple server.

Ben

On 6 Mar 2019, at 5:39, Kanika wrote:

> Hi,
> I am trying to deploy pnfs using the mainstream-ed NFSv4 server/client
> available with 4.15 kernels. I have been able to setup the MDS and
> client using the flexfile layout. I can't find any documentation on
> how to inform MDS about the data servers.
>
> The setup I have so far:
> Metadata server and data server are running Ubuntu 18.04
> Client is Centos 7.5
>
> MDS (intended), ip: 192.168.122.92
> root@ubuntu1804:~/#cat /etc/exports
> /sudosrv *(rw,sync,fsid=0,no_subtree_check,no_root_squash,pnfs) <-- 
> PNFS set
> /sudosrv/share1 *(rw,sync,fsid=1,no_subtree_check,no_root_squash)
>
> Intended DS, ip: 192.168.122.83
> root@ubuntu18_04_2:~#cat /etc/exports
> /srv/homes *(rw,sync,fsid=4,no_root_squash,no_subtree_check)
>
> Client, ip:192.168.122.5 (Centos 7.5)
> Mount the pseudo root filesystem exported by MDS
>
> #mount -t nfs -o v4.2 -o rw 192.168.122.92:/ /mnt/
> #cat /proc/self/mountstats
>
> device nfsd mounted on /proc/fs/nfsd with fstype nfsd
> device 192.168.122.92:/ mounted on /mnt with fstype nfs4 statvers=1.1
> opts: 
> rw,vers=4.2,rsize=524288,wsize=524288,namlen=255,acregmin=3,acregmax=60,acdirmin=30,acdirmax=60,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.122.5,local_lock=none
> age: 127
> impl_id: name='',domain='',date='0,0'
> caps: caps=0x1fbffdf,wtmult=512,dtsize=32768,bsize=0,namlen=255
> nfsv4: 
> bm0=0xfdffbfff,bm1=0x40f9be3e,bm2=0x20803,acl=0x3,sessions,pnfs=LAYOUT_FLEX_FILES
>  <--- flex file layout
> sec: flavor=1,pseudoflavor=1
>
> I tried 2 ways to link MDS and DS
> 1. Use the "refer" while exporting the DS share from MDS. This works
> as referrals are expected to work but not like "pnfs".
> 2. Mount the DS on MDS in a subdir of /sudosrv/share1. All IO
> operations go only to the MDS as if it were a local share. No exchange
> between the client and the DS.
>
> How can the DS be known to an MDS for a local filesystem like ext4?
> Any help will be appreciated.
>
> Thanks,
> jrk
