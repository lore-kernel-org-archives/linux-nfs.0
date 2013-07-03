Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:37174 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932845Ab3GCPLI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jul 2013 11:11:08 -0400
Received: from acsinet22.oracle.com (acsinet22.oracle.com [141.146.126.238])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r63FB7Rl023085
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 3 Jul 2013 15:11:08 GMT
Received: from aserz7021.oracle.com (aserz7021.oracle.com [141.146.126.230])
	by acsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r63FB6KS012149
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 3 Jul 2013 15:11:07 GMT
Received: from abhmt108.oracle.com (abhmt108.oracle.com [141.146.116.60])
	by aserz7021.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r63FB6FP002114
	for <linux-nfs@vger.kernel.org>; Wed, 3 Jul 2013 15:11:06 GMT
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: Question on tuning sunrpc.tcp_slot_table_entries
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <51D1EC91.9050308@oracle.com>
Date: Wed, 3 Jul 2013 11:11:05 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <74A31721-7179-420F-B70F-61561F8961A7@oracle.com>
References: <51D1EC91.9050308@oracle.com>
To: Jeff Wright <Jeff.Wright@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff-

On Jul 1, 2013, at 4:54 PM, Jeff Wright <Jeff.Wright@oracle.COM> wrote:

> Team,
> 
> I am supporting Oracle MOS note 1354980.1, which covers tuning clients for RMAN backup to the ZFS Storage Appliance.  One of the tuning recommendations is to change sunrpc.tcp_slot_table_entries from the default (16) to 128 to open up the number of concurrent I/O we can get per client mount point.  This is presumed good for general-purpose kernel NFS application traffic to the ZFS Storage Appliance.  I recently received the following comment regarding the efficacy of the sunrpc.tcp_slot_table_entries tune:
> 
> "In most cases, the parameter "sunrpc.tcp_slot_table_entries" can not be set even if applying int onto /etc/sysctl.conf although this document says users should do so.
> Because, the parameter is appeared after sunrpc.ko module is loaded(=NFS service is started), and sysctl was executed before starting NFS service."

I believe that assessment is correct.  It is also true that setting sunrpc.tcp_slot_table_entries has no effect on existing NFS mounts.  The value of this setting is copied each time a new RPC transport is created, and not referenced again.

A better approach might be to specify this setting via a module parameter, so it is set immediately whenever the sunrpc.ko module is loaded.  I haven't tested this myself.

The exact mechanism for hard-wiring a module parameter varies among distributions, but OL6 has the /etc/modprobe.d/ directory, where a .conf file can be added.  Something like this:

  sudo echo "options sunrpc tcp_slot_table_entries=128" > /etc/modprobe.d/sunrpc.conf

Then reboot, of course.

In more recent versions of the kernel, the maximum number of RPC slots is determined dynamically.  Looks like commit d9ba131d "SUNRPC: Support dynamic slot allocation for TCP connections", Sun Jul 17 18:11:30 2011, is the relevant commit.

That commit appeared upstream in kernel 3.1.  Definitely not in Oracle's UEKr1 or UEKr2 kernels.  No idea about recent RHEL/OL 6 updates, but I suspect not.

However, you might expect to see this feature in distributions containing more recent kernels, like RHEL 7; or it probably appears in the UEKr3 kernel (alphas are based on much more recent upstream kernels).

> I'd like to find out how to tell if the tune is actually in play for the running kernel and if there is a difference in what is reported /proc compared to what is running in core.

The nfsiostats command reports the size of the RPC backlog queue, which is a measure of whether the RPC slot table size is starving requests.  There are certain operations (WRITE, for example) which will have a long queue no matter what.

I can't think of a way of directly observing the slot table size in use for a particular mount.  That's been a perennial issue with this feature.

> Could anyone on the alias suggest how to validate if the aforementioned comment is relevant for the Linux kernel I am running with?  I am familiar with using mdb on Solaris to check what values the Solaris kernel is running with, so if there is a Linux equivalent, or another way to do this sort of thing with Linux, please let me know.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




