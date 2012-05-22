Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:27185 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750782Ab2EVQaa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 12:30:30 -0400
Received: from vmwexceht04-prd.hq.netapp.com (vmwexceht04-prd.hq.netapp.com [10.106.77.34])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q4MGUUQo028676
	for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 09:30:30 -0700 (PDT)
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSv4.1 do not release page on commit mismatch
Date: Tue, 22 May 2012 16:30:29 +0000
Message-ID: <4D70BD9B-4F81-4E57-8689-DCE6F8B1A1C2@netapp.com>
References: <1337688569-1515-1-git-send-email-andros@netapp.com>
 <1337688569-1515-5-git-send-email-andros@netapp.com>
 <1337703865.4269.21.camel@lade.trondhjem.org>
In-Reply-To: <1337703865.4269.21.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 22, 2012, at 12:24 PM, Myklebust, Trond wrote:

> On Tue, 2012-05-22 at 08:09 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfs/write.c |    2 ++
>> 1 files changed, 2 insertions(+), 0 deletions(-)
>> 
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index e6fe3d6..c7295de 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>> @@ -1555,6 +1555,8 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
>> 		/* We have a mismatch. Write the page again */
>> 		dprintk(" mismatch\n");
>> 		nfs_mark_request_dirty(req);
>> +		nfs_unlock_request(req);
>> +		continue;
>> 	next:
>> 		nfs_unlock_and_release_request(req);
>> 	}
> 
> What is this patch trying to fix? As far as I can see it will lead to a
> reference leak.

The release of the page drops the refcount to zero. Since it is a mismatch, we want to continue to use the page, so nfs_page_find_request_locked is called we get the WARNING in kref_get, and an Oops in various places in pnfs_update_layout.

Here is the output of added printk's.

-->Andy

May 21 18:25:33 fedora-64-2 kernel: [  152.988921] NFS:       commit (0:35/2 4096@184320)
May 21 18:25:33 fedora-64-2 kernel: [  152.988923]  mismatch req ffff880042dbb800
May 21 18:25:33 fedora-64-2 kernel: [  152.988927] nfs_release_request WB req ffff880042dbb800 wb_kref 1
May 21 18:25:33 fedora-64-2 kernel: [  152.988932] put_lseg: lseg ffff880042d95380 ref 4 valid 0
May 21 18:25:33 fedora-64-2 kernel: [  152.988945] nfs_page_find_request_locked req ffff88003e033800
May 21 18:25:33 fedora-64-2 kernel: [  152.988949] nfs_page_find_request_locked WB req ffff88003e033800 wb_kref 0
May 21 18:25:33 fedora-64-2 kernel: [  152.988953] ------------[ cut here ]------------
May 21 18:25:33 fedora-64-2 kernel: [  152.989082] WARNING: at include/linux/kref.h:41 kref_get+0x20/0x2c [nfs]()




May 21 18:25:33 fedora-64-2 kernel: [  152.989484] kernel BUG at fs/nfs/pnfs.c:584!
May 21 18:25:33 fedora-64-2 kernel: [  152.989488] invalid opcode: 0000 [#1] SMP
May 21 18:25:33 fedora-64-2 kernel: [  152.989493] CPU 1
May 21 18:25:33 fedora-64-2 kernel: [  152.989495] Modules linked in: nfs_layout_nfsv41_files nfs auth_rpcgss nfs_acl fuse lockd rfcomm bnep ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ip6table_filter ip6_tables snd_ens1371 gameport snd_rawmidi snd_ac97_codec ac97_bus snd_seq snd_seq_device btusb snd_pcm joydev bluetooth rfkill ppdev snd_timer vmw_balloon microcode snd parport_pc parport soundcore snd_page_alloc e1000 i2c_piix4 i2c_core shpchp uinput sunrpc mptspi mptscsih mptbase scsi_transport_spi [last unloaded: scsi_wait_scan]
May 21 18:25:33 fedora-64-2 kernel: [  152.989552]
May 21 18:25:33 fedora-64-2 kernel: [  152.989557] Pid: 1595, comm: flush-0:35 Tainted: G        W    3.4.0-rc7+ #5 VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform
May 21 18:25:33 fedora-64-2 kernel: [  152.989566] RIP: 0010:[<ffffffffa02c7377>]  [<ffffffffa02c7377>] pnfs_update_layout+0x460/0x6a6 [nfs]

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

