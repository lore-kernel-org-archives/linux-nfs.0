From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [patch for 2.6.30? 1/1] lockd: fix FILE_LOCKING=n build error
Date: Mon, 25 May 2009 15:47:26 -0700
Message-ID: <4A1B1FFE.6030209@oracle.com>
References: <200905122047.n4CKlP24029339@imap1.linux-foundation.org> <20090513195953.GF13420@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: akpm@linux-foundation.org, trond.myklebust@fys.uio.no,
	linux-nfs@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:57309 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753110AbZEYWp3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 May 2009 18:45:29 -0400
In-Reply-To: <20090513195953.GF13420@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Tue, May 12, 2009 at 01:28:09PM -0700, akpm@linux-foundation.org wrote:
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>>
>> lockd/svclock.c is missing a header file <linux/fs.h>.
>>
>> <linux/fs.h> is missing a definition of locks_release_private()
>> for the config case of FILE_LOCKING=n, causing a build error:
>>
>> fs/lockd/svclock.c:330: error: implicit declaration of function 'locks_release_private'
>>
> 
> Thanks, applied for 2.6.31.

linux-next builds still fail since this patch isn't in linux-next.
Is there a way to have this patch in some linux-next tree?

Thanks.

> --b.
> 
>> lockd without FILE_LOCKING doesn't make sense, so make LOCKD and LOCKD_V4
>> depend on FILE_LOCKING, and make NFS depend on FILE_LOCKING.
>>
>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
>> Cc: Bruce Fields <bfields@fieldses.org>
>> Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>
>>  fs/Kconfig     |    2 ++
>>  fs/nfs/Kconfig |    2 +-
>>  2 files changed, 3 insertions(+), 1 deletion(-)
>>
>> diff -puN fs/Kconfig~lockd-fix-file_locking=n-build-error fs/Kconfig
>> --- a/fs/Kconfig~lockd-fix-file_locking=n-build-error
>> +++ a/fs/Kconfig
>> @@ -236,10 +236,12 @@ source "fs/nfsd/Kconfig"
>>  
>>  config LOCKD
>>  	tristate
>> +	depends on FILE_LOCKING
>>  
>>  config LOCKD_V4
>>  	bool
>>  	depends on NFSD_V3 || NFS_V3
>> +	depends on FILE_LOCKING
>>  	default y
>>  
>>  config EXPORTFS
>> diff -puN fs/nfs/Kconfig~lockd-fix-file_locking=n-build-error fs/nfs/Kconfig
>> --- a/fs/nfs/Kconfig~lockd-fix-file_locking=n-build-error
>> +++ a/fs/nfs/Kconfig
>> @@ -1,6 +1,6 @@
>>  config NFS_FS
>>  	tristate "NFS client support"
>> -	depends on INET
>> +	depends on INET && FILE_LOCKING
>>  	select LOCKD
>>  	select SUNRPC
>>  	select NFS_ACL_SUPPORT if NFS_V3_ACL
>> _


-- 
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
