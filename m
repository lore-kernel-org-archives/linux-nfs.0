Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19420 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753200Ab0LCSBh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Dec 2010 13:01:37 -0500
Message-ID: <4CF9307D.9040504@parallels.com>
Date: Fri, 03 Dec 2010 21:01:33 +0300
From: Kinsbursky Stanislav <skinsbursky@parallels.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] NFS: suppressing showing of default mount port value
 in /proc fixed
References: <20101203170138.22955.86546.stgit@localhost6.localdomain6> <7AF6FF7E-F57C-493B-8880-25509CC54EDE@oracle.com>
In-Reply-To: <7AF6FF7E-F57C-493B-8880-25509CC54EDE@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

03.12.2010 20:35, Chuck Lever пишет:
>
> On Dec 3, 2010, at 12:11 PM, Stanislav Kinsbursky wrote:
>
>> Default value for mount server port is set to NFS_UNSPEC_PORT (-1) and will not
>> be changed during parsing mount options for mound data version 6. This default
>> value will be showed for mountport in /proc/mounts always since current default
>> check is for zero value. This small mistake leads to big problem, because
>> during umount.nfs execution from old user-space utils (at least nfs-utils
>> 1.0.9) this value will be used as the server port to connect to. This request
>> will be rejected (since port is 65535) and thus nfs mount point can't be
>> unmounted.
>
> Note: this is only possible if /etc/mtab is a link to /proc/mounts.  Not all systems have this configuration.
>

I found it on CentOs 5.5 with RHEL6 kernel.
Actually, the current patch has a specific flaw: if mount port is not passed by nfs utils using mount options version 6, then it will be set to 0 and showed in /proc/mounts as "mountport=0".
Another fix solution is to call "nfs_set_port(sap, &args->nfs_server.port, 0);" when parsing mount options version 6 (like in done in default casein nfs_validate_mount_data) instead of changing 
nfs_show_mountd_options().


>>
>> Kernel version affected: 2.6.37-rc4
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>
>> ---
>> fs/nfs/super.c |    3 ++-
>> 1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 6d6e21d..fd4cac8 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -681,7 +681,8 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
>>
>> 	if (nfss->mountd_version || showdefaults)
>> 		seq_printf(m, ",mountvers=%u", nfss->mountd_version);
>> -	if (nfss->mountd_port || showdefaults)
>> +	if (nfss->mountd_port != (unsigned short)NFS_UNSPEC_PORT ||
>> +			showdefaults)
>> 		seq_printf(m, ",mountport=%u", nfss->mountd_port);
>>
>> 	nfs_show_mountd_netid(m, nfss, showdefaults);
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Best regards,
Stanislav Kinsbursky
