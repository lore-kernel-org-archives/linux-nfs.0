From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Bug#476577: corrected patch
Date: Mon, 21 Apr 2008 11:59:07 -0400
Message-ID: <40FD052D-BBC2-4AE4-BEF3-56914D39E13A@oracle.com>
References: <20080417200928.GA20809@kodama.kitenet.net> <20080420223416.GA12722@uio.no>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, Joey Hess <joeyh@debian.org>,
	476577@bugs.debian.org
To: "Steinar H. Gunderson" <sesse@debian.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:28817 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756106AbYDUQBD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2008 12:01:03 -0400
In-Reply-To: <20080420223416.GA12722-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 20, 2008, at 6:34 PM, Steinar H. Gunderson wrote:
> Hi guys,
>
> Would you please consider this patch for inclusion into upstream? It  
> looks
> more than reasonable to me, at least.

What if /etc/mtab is a symlink to a valid writable file that is not / 
proc/mounts?  The test you introduce below will prevent that case from  
working properly.

Is there a security issue with creating a file in / when /proc isn't  
mounted, or is this just an inconvenience?

> /* Steinar */
>
> On Thu, Apr 17, 2008 at 04:09:28PM -0400, Joey Hess wrote:
>> Hmm, nmudiff did not send in the patch I expected. Here is a
>> corrected/tested one.
>>
>> -- 
>> see shy jo
>
>> diff -ur foo/nfs-utils-1.1.2/debian/changelog nfs-utils-1.1.2/ 
>> debian/changelog
>> --- foo/nfs-utils-1.1.2/debian/changelog	2008-04-17  
>> 16:06:27.000000000 -0400
>> +++ nfs-utils-1.1.2/debian/changelog	2008-04-17 15:33:41.000000000  
>> -0400
>> @@ -1,3 +1,10 @@
>> +nfs-utils (1:1.1.2-2.1) UNRELEASED; urgency=low
>> +
>> +  * Avoid writing to or fchmodding /etc/mtab if it is a symlink.
>> +    Closes: #476577
>> +
>> + -- Joey Hess <joeyh@debian.org>  Thu, 17 Apr 2008 15:30:49 -0400
>> +
>> nfs-utils (1:1.1.2-2) unstable; urgency=low
>>
>>   * Remove ${misc:Depends} from binary variables -- it is not used,  
>> and not
>> diff -ur foo/nfs-utils-1.1.2/utils/mount/fstab.c nfs-utils-1.1.2/ 
>> utils/mount/fstab.c
>> --- foo/nfs-utils-1.1.2/utils/mount/fstab.c	2008-03-14  
>> 11:46:29.000000000 -0400
>> +++ nfs-utils-1.1.2/utils/mount/fstab.c	2008-04-17  
>> 15:40:01.000000000 -0400
>> @@ -52,7 +52,7 @@
>> 	return var_mtab_does_not_exist;
>> }
>>
>> -static int
>> +int
>> mtab_is_a_symlink(void) {
>>         get_mtab_info();
>>         return var_mtab_is_a_symlink;
>> diff -ur foo/nfs-utils-1.1.2/utils/mount/fstab.h nfs-utils-1.1.2/ 
>> utils/mount/fstab.h
>> --- foo/nfs-utils-1.1.2/utils/mount/fstab.h	2008-03-14  
>> 11:46:29.000000000 -0400
>> +++ nfs-utils-1.1.2/utils/mount/fstab.h	2008-04-17  
>> 15:38:30.000000000 -0400
>> @@ -7,6 +7,7 @@
>> #define _PATH_FSTAB "/etc/fstab"
>> #endif
>>
>> +int mtab_is_a_symlink(void);
>> int mtab_is_writable(void);
>> int mtab_does_not_exist(void);
>>
>> diff -ur foo/nfs-utils-1.1.2/utils/mount/mount.c nfs-utils-1.1.2/ 
>> utils/mount/mount.c
>> --- foo/nfs-utils-1.1.2/utils/mount/mount.c	2008-03-14  
>> 11:46:29.000000000 -0400
>> +++ nfs-utils-1.1.2/utils/mount/mount.c	2008-04-17  
>> 15:39:34.000000000 -0400
>> @@ -257,6 +257,13 @@
>> 		return EX_SUCCESS;
>> 	}
>>
>> +        /* Avoid writing if the mtab is a symlink to /proc/mounts,  
>> since
>> +	   that would create a file /proc/mounts in case the proc  
>> filesystem
>> +           is not mounted, and the fchmod below would also fail. */
>> +	if (mtab_is_a_symlink()) {
>> +		return EX_SUCCESS;
>> +	}
>> +
>> 	lock_mtab();
>>
>> 	mtab = nfs_setmntent(MOUNTED, "a+");
>
>
>
>
> -- 
> Homepage: http://www.sesse.net/
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



