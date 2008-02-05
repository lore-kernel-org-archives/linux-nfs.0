From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 5/5] NFSD: Use "depends on" for PROC_FS dependency
Date: Mon, 4 Feb 2008 19:37:12 -0500
Message-ID: <8019EFEE-F0DA-4CF6-9E11-B8476581B689@oracle.com>
References: <20080205000450.18602.4797.stgit@manray.1015granger.net> <463F2346-A02C-4781-800F-16282B90331D@oracle.com> <20080205003017.GJ32086@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:29087 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754745AbYBEAhs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2008 19:37:48 -0500
In-Reply-To: <20080205003017.GJ32086@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 4, 2008, at 7:30 PM, J. Bruce Fields wrote:
> On Mon, Feb 04, 2008 at 07:28:18PM -0500, Chuck Lever wrote:
>> Sigh.  I see this is broken already.
>
> What was the problem?

[cel@manray nfs-2.6]$ make menuconfig
   GEN     /u/cel/obj/Makefile
scripts/kconfig/mconf arch/x86/Kconfig
fs/Kconfig:1751:error: found recursive dependency: NFSD_V4 ->  
RPCSEC_GSS_KRB5 -> SUNRPC_GSS -> PROC_FS -> NFSD_V4
  -> CRYPTO -> CRYPTO_ANUBISmake[2]: *** [menuconfig] Error 1
make[1]: *** [menuconfig] Error 2
make: *** [sub-make] Error 2
[cel@manray nfs-2.6]$

That may be because of the other issue I noticed: that NFSD_V4  
selects RPCSEC_GSS_KRB5, which is a visible config entry.

>> It may be the case that "select ... if ..." is the only way to do  
>> this.
>>
>> On Feb 4, 2008, at 7:04 PM, Chuck Lever wrote:
>>
>>> Recently a reverse dependency was added to fs/Kconfig to ensure that
>>> PROC_FS was enabled if NFSD_V4 was enabled.
>>>
>>> There is a guideline in Documentation/kbuild/kconfig-language.txt  
>>> that
>>> states "In general use select only for non-visible symbols (no  
>>> prompts
>>> anywhere) and for symbols with no dependencies."
>>>
>>> A quick grep around other Kconfig files reveals that no entry
>>> currently
>>> uses "select PROC_FS" -- every one uses "depends on".  Thus
>>> CONFIG_NFSD_V4
>>> should use "depends on PROC_FS" as well.
>>>
>>> For SUNRPC_GSS, it's a little more complex.  Other entries can
>>> "select"
>>> SUNRPC_GSS, as it is non-visible.  However, the guideline  
>>> suggests an
>>> entry can't "select" it if it has a dependency (such as PROC_FS).
>>>
>>> Another problem is that if a tristate entry (SUNRPC_GSS) "depends  
>>> on" a
>>> boolean (PROC_FS) we can't set the tristate entry to M.
>>>
>>> XXX: Both CONFIG_NFSV4 and CONFIG_NFSD_V4 select RPCSEC_GSS_KRB5,
>>> which is
>>> visible, which kconfig-language.txt also frowns upon.  The intent  
>>> was
>>> to
>>> enable at least one GSS mechanism if V4 was enabled.  Perhaps we
>>> should
>>> make SUNRPC_GSS visible, and make the NFSv4 options visible only if
>>> SUNRPC_GSS is enabled.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>>  fs/Kconfig |    3 +--
>>>  1 files changed, 1 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/fs/Kconfig b/fs/Kconfig
>>> index 5ccff9a..d689226 100644
>>> --- a/fs/Kconfig
>>> +++ b/fs/Kconfig
>>> @@ -1689,7 +1689,6 @@ config NFSD
>>>  	select CRYPTO_MD5 if NFSD_V4
>>>  	select CRYPTO if NFSD_V4
>>>  	select FS_POSIX_ACL if NFSD_V4
>>> -	select PROC_FS if NFSD_V4
>>>  	select PROC_FS if SUNRPC_GSS
>>>  	help
>>>  	  Say Y here if you want to allow other computers to access files
>>> @@ -1750,7 +1749,7 @@ config NFSD_V3_ACL
>>>
>>>  config NFSD_V4
>>>  	bool "Provide NFSv4 server support (EXPERIMENTAL)"
>>> -	depends on NFSD && NFSD_V3 && EXPERIMENTAL
>>> +	depends on NFSD && NFSD_V3 && PROC_FS && EXPERIMENTAL
>>>  	select RPCSEC_GSS_KRB5
>>>  	help
>>>  	  This option enables support in your system's NFS server for
>>>
>>> -
>>> To unsubscribe from this list: send the line "unsubscribe linux- 
>>> nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>>
>>
>>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



