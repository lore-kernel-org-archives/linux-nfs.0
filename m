Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:37578 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbcALM6F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Jan 2016 07:58:05 -0500
Subject: Re: blk_update_request: I/O error on NFS
To: Wei Liu <wei.liu2@citrix.com>,
        =?UTF-8?Q?Kojedzinszky_Rich=c3=a1rd?=
	<kojedzinszky.richard@euronetrt.hu>,
        Xen-devel <xen-devel@lists.xenproject.org>
References: <alpine.DEB.2.20.1601111458420.24727@krichy.tvnetwork.hu>
 <20160112120548.GB27051@citrix.com>
CC: <linux-nfs@vger.kernel.org>,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
From: =?UTF-8?Q?Roger_Pau_Monn=c3=a9?= <roger.pau@citrix.com>
Message-ID: <5694F858.1040007@citrix.com>
Date: Tue, 12 Jan 2016 13:58:00 +0100
MIME-Version: 1.0
In-Reply-To: <20160112120548.GB27051@citrix.com>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

El 12/01/16 a les 13.05, Wei Liu ha escrit:
> Drop xen-users@, CC xen-devel@ and blk maintainers, change title.
> 
> On Mon, Jan 11, 2016 at 03:08:24PM +0100, Kojedzinszky Richárd wrote:
>> Dear all,
>>
>> We are facing a regular lockup with our xen setup. We have an nfs share
>> mounted on the xen dom0, where the vm images are served, and those files are
>> given to xen domUs.
>>
>> I was just preparing an experiment, where I created a 100G file on the host:
>> # truncate -s 100G /srv/nfs/domU/disk2
>> And after added this disk to the instance's configuration.

Have you tried creating the file with dd instead of truncate? (so it's
not sparse)

>> On the host this is the mountpoint:
>> # mount|grep srv/xen
>> 10.1.1.1:/mnt/main/vps on /srv/xen type nfs (rw,relatime,vers=3,rsize=16384,wsize=16384,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.1.1.1,mountvers=3,mountport=4045,mountproto=udp,local_lock=none,addr=10.1.1.1)
>>
>> After starting the instance I partitioned the disk with gdisk, and created
>> an xfs fs on it. While the fs has been created well, strange messages
>> appeared on the console:

AFAICT this is the guest console. Is there any corresponding error on
the host console?

>> [   23.787504] blk_update_request: I/O error, dev xvdc, sector 2048
>> [   23.788904] blk_update_request: I/O error, dev xvdc, sector 8390655
>> [   23.789611] blk_update_request: I/O error, dev xvdc, sector 16779262
>> [   23.790359] blk_update_request: I/O error, dev xvdc, sector 25167869
>> [   23.791148] blk_update_request: I/O error, dev xvdc, sector 33556476
>> [   23.791498] blk_update_request: I/O error, dev xvdc, sector 41945083
>> [   23.791498] blk_update_request: I/O error, dev xvdc, sector 50333690
>> [   23.791498] blk_update_request: I/O error, dev xvdc, sector 58722297
>> [   23.791498] blk_update_request: I/O error, dev xvdc, sector 67110904
>> [   23.791498] blk_update_request: I/O error, dev xvdc, sector 75499511
>>
>> I dont think that this is normal. If I chose a local block device (probably
>> lvm) for the domU, this does not appear.

IIRC Xen 4.4 still uses Qemu (Qdisk) for raw disks, do you have any kind
of errors/warnings in /var/log/xen/qemu-dm-<domain_name>.log?

Roger.

