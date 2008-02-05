From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 5/5] NFSD: Use "depends on" for PROC_FS dependency
Date: Mon, 4 Feb 2008 19:30:17 -0500
Message-ID: <20080205003017.GJ32086@fieldses.org>
References: <20080205000450.18602.4797.stgit@manray.1015granger.net> <463F2346-A02C-4781-800F-16282B90331D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:58313 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756838AbYBEAaV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2008 19:30:21 -0500
In-Reply-To: <463F2346-A02C-4781-800F-16282B90331D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 04, 2008 at 07:28:18PM -0500, Chuck Lever wrote:
> Sigh.  I see this is broken already.

What was the problem?

--b.

>
> It may be the case that "select ... if ..." is the only way to do this.
>
> On Feb 4, 2008, at 7:04 PM, Chuck Lever wrote:
>
>> Recently a reverse dependency was added to fs/Kconfig to ensure that
>> PROC_FS was enabled if NFSD_V4 was enabled.
>>
>> There is a guideline in Documentation/kbuild/kconfig-language.txt that
>> states "In general use select only for non-visible symbols (no prompts
>> anywhere) and for symbols with no dependencies."
>>
>> A quick grep around other Kconfig files reveals that no entry  
>> currently
>> uses "select PROC_FS" -- every one uses "depends on".  Thus  
>> CONFIG_NFSD_V4
>> should use "depends on PROC_FS" as well.
>>
>> For SUNRPC_GSS, it's a little more complex.  Other entries can  
>> "select"
>> SUNRPC_GSS, as it is non-visible.  However, the guideline suggests an
>> entry can't "select" it if it has a dependency (such as PROC_FS).
>>
>> Another problem is that if a tristate entry (SUNRPC_GSS) "depends on" a
>> boolean (PROC_FS) we can't set the tristate entry to M.
>>
>> XXX: Both CONFIG_NFSV4 and CONFIG_NFSD_V4 select RPCSEC_GSS_KRB5,  
>> which is
>> visible, which kconfig-language.txt also frowns upon.  The intent was 
>> to
>> enable at least one GSS mechanism if V4 was enabled.  Perhaps we  
>> should
>> make SUNRPC_GSS visible, and make the NFSv4 options visible only if
>> SUNRPC_GSS is enabled.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>>  fs/Kconfig |    3 +--
>>  1 files changed, 1 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/Kconfig b/fs/Kconfig
>> index 5ccff9a..d689226 100644
>> --- a/fs/Kconfig
>> +++ b/fs/Kconfig
>> @@ -1689,7 +1689,6 @@ config NFSD
>>  	select CRYPTO_MD5 if NFSD_V4
>>  	select CRYPTO if NFSD_V4
>>  	select FS_POSIX_ACL if NFSD_V4
>> -	select PROC_FS if NFSD_V4
>>  	select PROC_FS if SUNRPC_GSS
>>  	help
>>  	  Say Y here if you want to allow other computers to access files
>> @@ -1750,7 +1749,7 @@ config NFSD_V3_ACL
>>
>>  config NFSD_V4
>>  	bool "Provide NFSv4 server support (EXPERIMENTAL)"
>> -	depends on NFSD && NFSD_V3 && EXPERIMENTAL
>> +	depends on NFSD && NFSD_V3 && PROC_FS && EXPERIMENTAL
>>  	select RPCSEC_GSS_KRB5
>>  	help
>>  	  This option enables support in your system's NFS server for
>>
>> -
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
