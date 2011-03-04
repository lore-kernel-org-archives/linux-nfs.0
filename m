Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23931 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759966Ab1CDQXl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Mar 2011 11:23:41 -0500
Message-ID: <4D711209.9060804@RedHat.com>
Date: Fri, 04 Mar 2011 11:23:37 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Karel Zak <kzak@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] mount: add --enable-libmount-mount
References: <1299159822-25190-1-git-send-email-kzak@redhat.com> <1299159822-25190-3-git-send-email-kzak@redhat.com> <4D6FF1A2.8060205@RedHat.com> <20110304101842.GA1655@nb.net.home>
In-Reply-To: <20110304101842.GA1655@nb.net.home>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 03/04/2011 05:18 AM, Karel Zak wrote:
> On Thu, Mar 03, 2011 at 02:53:06PM -0500, Steve Dickson wrote:
>>> +	opts = retrieve_mount_options(mnt_context_get_fs(cxt));
>>> +
>>> +	if (!mnt_context_is_lazy(cxt)) {
>>> +		if (opts) {
>>> +			/* we have full FS description (e.g. from mtab or /proc) */
>>> +			switch (is_vers4(cxt)) {
>>> +			case 0:
>>> +				/* We ignore the error from nfs_umount23.
>>> +				 * If the actual umount succeeds (in del_mtab),
>>> +				 * we don't want to signal an error, as that
>>> +				 * could cause /sbin/mount to retry!
>>> +				 */
>>> +				nfs_umount23(mnt_context_get_source(cxt), opts);
>>> +				break;
>>> +			case 1:			/* unknown */
>>> +				break;
>>> +			default:		/* error */
>>> +				goto err;
>>> +			}
>>> +		} else
>>> +			/* strange, no entry in mtab or /proc not mounted */
>>> +			nfs_umount23(spec, "tcp,v3");
>> Question: since retrieve_mount_options() returns NULL why do you assume 
>> the mount exists?
> 
>  because on systems with /etc/mtab is possible that the file is empty,
>  so we have no clue about the mount point.
Ah... I am so glad mtab is going away! 

>  
>  This is normal umount(8) behavior, for root user it always tries to
>  call umount(2) syscall. We should not assume that there is usable
>  /proc or /etc/mtab. It's important be able to umount any device
>  independently on /proc or /etc.
> 
>  See nfsumount.c, the current code uses the same logic.
Got it..

> 
>> What's happing is I'm doing an umount.nfs on an 
>> not existing mount point and the error is 
>>     umount.nfs: remote share not in 'host:dir' format
>>
>> Instead of
>>     umount.nfs: /mnt/home: not mounted
> 
>  Good catch, this is bug. There is missing umount_error();
> 
>  I'll update the patch and add your change to mount_config_init() too.
Thank you...

steved.
