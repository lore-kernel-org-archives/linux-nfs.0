From: Richard A Nelson <cowboy@linux.vnet.ibm.com>
Subject: Re: NFS/AFS/Selinux issues with 2.26.29
Date: Wed, 25 Mar 2009 17:42:32 -0700
Message-ID: <49CACF78.80305@linux.vnet.ibm.com>
References: <49CAAB9B.5070104@linux.vnet.ibm.com> <1238020424.26487.81.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	openafs-devel-UX5vO7D78FVAfugRpC6u6w@public.gmane.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:56898 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751070AbZCZAml (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Mar 2009 20:42:41 -0400
In-Reply-To: <1238020424.26487.81.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Wed, 2009-03-25 at 15:09 -0700, Richard A Nelson wrote:
>> 1) 2.6.29 NFS clients can no longer lock files:
...
> 
> Given that you are claiming to be seeing selinux problems on
> 2.6.29-based servers, 

Yeah, I fixed the SeLinux issues by disabling it at boot

> could you therefore please check again after
> downgrading the server kernel?

I dropped the server to:
# uname -a
Linux el-ghor 2.6.28.8 #19 SMP Sun Mar 22 18:41:28 UTC 2009 x86_64 GNU/Linux

And still see same lockfile error.

However, a typo showed that locking is indeed working fine - for everything
except one directory tree (/root/Mail) ... re-mounting and even rebooting one
of the failing clients didn't help.

mounts are nfs3,sec=sys,posix,... and the server filesystem is ext3 w/acls
rpc.statd is active on all systems, and there is no firewall in the way

So now the server and one client have been rebooted, and the client can
lock files anywhere but the directory tree for /root/Mail
sm-notify -f (from the client) didn't help

Somewhere, there is persistant state that is keeping two out of three
local systems from creating locks and it all started after upgrading the
kernel ... colour me dazed and confused, but trying to continue ;)

/me goes in search of lock display tools (cat /proc/locks isn't yet enough for me)
-- 
Rick
