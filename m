From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 07/11] NFSD: Use "depends on" for PROC_FS dependency
Date: Tue, 12 Feb 2008 17:10:57 -0500
Message-ID: <9C44C93A-AC87-4B21-8E31-872186ABCEBB@oracle.com>
References: <20080211221216.1047.31922.stgit@manray.1015granger.net> <20080212212325.GM18625@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:62836 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536AbYBLWL2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Feb 2008 17:11:28 -0500
In-Reply-To: <20080212212325.GM18625@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 12, 2008, at 4:23 PM, J. Bruce Fields wrote:

> On Mon, Feb 11, 2008 at 05:12:16PM -0500, Chuck Lever wrote:
>> Recently, commit 440bcc59 added a reverse dependency to fs/Kconfig to
>> ensure that PROC_FS was enabled if NFSD_V4 was enabled.
>>
>> There is a guideline in Documentation/kbuild/kconfig-language.txt  
>> that
>> states "In general use select only for non-visible symbols (no  
>> prompts
>> anywhere) and for symbols with no dependencies."
>>
>> A quick grep around other Kconfig files reveals that no entry  
>> currently
>> uses "select PROC_FS" -- every one uses "depends on".  Thus  
>> CONFIG_NFSD_V4
>> should use "depends on PROC_FS" as well.
>
> OK.
>
>>
>> For SUNRPC_GSS, it's a little more complex.  Other entries can  
>> "select"
>> SUNRPC_GSS, as it is non-visible.  However, the guideline suggests an
>> entry can't "select" it if it has a dependency (such as PROC_FS).
>> So, we add forward dependencies on PROC_FS to RPCSEC_GSS_FOO instead.
>
> This also makes the client dependent on PROC_FS, which it wasn't  
> before.
>
> I assume nobody cares?

Huh?  If I disable PROC_FS, I can still select the NFS client  
options, even NFSv4.

>> XXX: Both CONFIG_NFSV4 and CONFIG_NFSD_V4 select RPCSEC_GSS_KRB5,  
>> which is
>> visible, which kconfig-language.txt also frowns upon.  The intent  
>> was to
>> enable at least one GSS mechanism if V4 was enabled.  Perhaps we  
>> should
>> make SUNRPC_GSS visible, and make the NFSv4 options visible only if
>> SUNRPC_GSS is enabled.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>>  fs/Kconfig |    8 +++-----
>>  1 files changed, 3 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/Kconfig b/fs/Kconfig
>> index 0c8f85d..9ee288f 100644
>> --- a/fs/Kconfig
>> +++ b/fs/Kconfig
>> @@ -1662,8 +1662,6 @@ config NFSD
>>  	select CRYPTO_MD5 if NFSD_V4
>>  	select CRYPTO if NFSD_V4
>>  	select FS_POSIX_ACL if NFSD_V4
>> -	select PROC_FS if NFSD_V4
>> -	select PROC_FS if SUNRPC_GSS
>>  	help
>>  	  Choose Y here if you want to allow other computers to access
>>  	  files residing on this system using Sun's Network File System
>> @@ -1723,7 +1721,7 @@ config NFSD_V3_ACL
>>
>>  config NFSD_V4
>>  	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
>> -	depends on NFSD && NFSD_V3 && EXPERIMENTAL
>> +	depends on NFSD && NFSD_V3 && PROC_FS && EXPERIMENTAL
>>  	select RPCSEC_GSS_KRB5
>>  	help
>>  	  This option enables support in your system's NFS server for
>> @@ -1798,7 +1796,7 @@ config SUNRPC_BIND34
>>
>>  config RPCSEC_GSS_KRB5
>>  	tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
>> -	depends on SUNRPC && EXPERIMENTAL
>> +	depends on SUNRPC && PROC_FS && EXPERIMENTAL
>>  	select SUNRPC_GSS
>>  	select CRYPTO
>>  	select CRYPTO_MD5
>> @@ -1817,7 +1815,7 @@ config RPCSEC_GSS_KRB5
>>
>>  config RPCSEC_GSS_SPKM3
>>  	tristate "Secure RPC: SPKM3 mechanism (EXPERIMENTAL)"
>> -	depends on SUNRPC && EXPERIMENTAL
>> +	depends on SUNRPC && PROC_FS && EXPERIMENTAL
>>  	select SUNRPC_GSS
>>  	select CRYPTO
>>  	select CRYPTO_MD5
>>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



