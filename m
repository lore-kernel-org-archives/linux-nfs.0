Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:16756 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970Ab3GCPXZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jul 2013 11:23:25 -0400
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r63FH312007429
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 3 Jul 2013 15:17:04 GMT
Received: from userz7022.oracle.com (userz7022.oracle.com [156.151.31.86])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r63FNMWY004295
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 3 Jul 2013 15:23:23 GMT
Received: from abhmt110.oracle.com (abhmt110.oracle.com [141.146.116.62])
	by userz7022.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r63FNMcY015413
	for <linux-nfs@vger.kernel.org>; Wed, 3 Jul 2013 15:23:22 GMT
Message-ID: <51D441E9.2050109@oracle.com>
Date: Wed, 03 Jul 2013 09:23:21 -0600
From: Jeff Wright <jeff.wright@oracle.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Question on tuning sunrpc.tcp_slot_table_entries
References: <51D1EC91.9050308@oracle.com> <74A31721-7179-420F-B70F-61561F8961A7@oracle.com>
In-Reply-To: <74A31721-7179-420F-B70F-61561F8961A7@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck,

Thank you for the response.  I'll remove the particular tune from the 
MOS note in the short term and I'll figure out a reliable procedure to 
make the tune in the long term.  I'll start with your recommendation in 
the modprobe.d/sunrpc.conf file.

I appreciate your help.

Jeff

On 07/03/13 09:11, Chuck Lever wrote:
> Hi Jeff-
>
> On Jul 1, 2013, at 4:54 PM, Jeff Wright<Jeff.Wright@oracle.COM>  wrote:
>
>> Team,
>>
>> I am supporting Oracle MOS note 1354980.1, which covers tuning clients for RMAN backup to the ZFS Storage Appliance.  One of the tuning recommendations is to change sunrpc.tcp_slot_table_entries from the default (16) to 128 to open up the number of concurrent I/O we can get per client mount point.  This is presumed good for general-purpose kernel NFS application traffic to the ZFS Storage Appliance.  I recently received the following comment regarding the efficacy of the sunrpc.tcp_slot_table_entries tune:
>>
>> "In most cases, the parameter "sunrpc.tcp_slot_table_entries" can not be set even if applying int onto /etc/sysctl.conf although this document says users should do so.
>> Because, the parameter is appeared after sunrpc.ko module is loaded(=NFS service is started), and sysctl was executed before starting NFS service."
> I believe that assessment is correct.  It is also true that setting sunrpc.tcp_slot_table_entries has no effect on existing NFS mounts.  The value of this setting is copied each time a new RPC transport is created, and not referenced again.
>
> A better approach might be to specify this setting via a module parameter, so it is set immediately whenever the sunrpc.ko module is loaded.  I haven't tested this myself.
>
> The exact mechanism for hard-wiring a module parameter varies among distributions, but OL6 has the /etc/modprobe.d/ directory, where a .conf file can be added.  Something like this:
>
>    sudo echo "options sunrpc tcp_slot_table_entries=128">  /etc/modprobe.d/sunrpc.conf
>
> Then reboot, of course.
>
> In more recent versions of the kernel, the maximum number of RPC slots is determined dynamically.  Looks like commit d9ba131d "SUNRPC: Support dynamic slot allocation for TCP connections", Sun Jul 17 18:11:30 2011, is the relevant commit.
>
> That commit appeared upstream in kernel 3.1.  Definitely not in Oracle's UEKr1 or UEKr2 kernels.  No idea about recent RHEL/OL 6 updates, but I suspect not.
>
> However, you might expect to see this feature in distributions containing more recent kernels, like RHEL 7; or it probably appears in the UEKr3 kernel (alphas are based on much more recent upstream kernels).
>
>> I'd like to find out how to tell if the tune is actually in play for the running kernel and if there is a difference in what is reported /proc compared to what is running in core.
> The nfsiostats command reports the size of the RPC backlog queue, which is a measure of whether the RPC slot table size is starving requests.  There are certain operations (WRITE, for example) which will have a long queue no matter what.
>
> I can't think of a way of directly observing the slot table size in use for a particular mount.  That's been a perennial issue with this feature.
>
>> Could anyone on the alias suggest how to validate if the aforementioned comment is relevant for the Linux kernel I am running with?  I am familiar with using mdb on Solaris to check what values the Solaris kernel is running with, so if there is a Linux equivalent, or another way to do this sort of thing with Linux, please let me know.

