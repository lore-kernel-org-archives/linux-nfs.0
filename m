From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 5/5] NFS: NFS_V4 and NFSD_V4 should depend on SUNRPC_GSS
Date: Mon, 17 Mar 2008 12:59:34 -0400
Message-ID: <0951705D-9F24-4E6F-B034-255C1A6655DB@oracle.com>
References: <20080314181525.29889.35370.stgit@manray.1015granger.net> <1205769601.11303.10.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:60524 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598AbYCQRAg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Mar 2008 13:00:36 -0400
In-Reply-To: <1205769601.11303.10.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 17, 2008, at 12:00 PM, Trond Myklebust wrote:
> On Fri, 2008-03-14 at 14:15 -0400, Chuck Lever wrote:
>> There is a guideline in Documentation/kbuild/kconfig-language.txt  
>> that
>> states "In general use select only for non-visible symbols (no  
>> prompts
>> anywhere) and for symbols with no dependencies." Both  
>> CONFIG_NFS_V4 and
>> CONFIG_NFSD_V4 select RPCSEC_GSS_KRB5, which is visible, and has
>> dependencies.
>>
>> For the sake of addressing the kconfig-language recommendation,
>> "select RPCSEC_GSS_KRB5" to "select SUNRPC_GSS".
>>
>> The server side requires it to build properly, and the client side  
>> has it
>> to provide support for loading GSS capabilities, which RFC 3530 makes
>> mandatory for NFS version 4.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>>  fs/Kconfig |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/Kconfig b/fs/Kconfig
>> index bbc8e52..28b7ba5 100644
>> --- a/fs/Kconfig
>> +++ b/fs/Kconfig
>> @@ -1628,7 +1628,7 @@ config NFS_V3_ACL
>>  config NFS_V4
>>  	bool "NFS client support for NFS version 4 (EXPERIMENTAL)"
>>  	depends on NFS_FS && EXPERIMENTAL
>> -	select RPCSEC_GSS_KRB5
>> +	select SUNRPC_GSS
>>  	help
>>  	  This option enables support for version 4 of the NFS protocol
>>  	  (RFC 3530) in the kernel's NFS client.
>> @@ -1719,7 +1719,7 @@ config NFSD_V4
>>  	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
>>  	depends on NFSD && PROC_FS && EXPERIMENTAL
>>  	select NFSD_V3
>> -	select RPCSEC_GSS_KRB5
>> +	select SUNRPC_GSS
>>  	help
>>  	  This option enables support in your system's NFS server for
>>  	  version 4 of the NFS protocol (RFC 3530).
>
> NACK.

A little discussion first would be more friendly.

> Selecting SUNRPC_GSS is _not_ equivalent to what we have today.
> Currently, if you select NFSv4, it will force compilation of the
> KerberosV mechanism too. AFAICS, this patch regresses that behaviour.


Enforcing that behavior breaks the rules of Kconfig.

The purpose of Kconfig is to allow the kernel to build correctly.   
The resulting configuration does not have to make sense from a run- 
time perspective.

Normally the way this sort of thing is handled is that a note is left  
in the help text that says "Oh, and you will find enabling Kerberos V  
support useful since the spec requires it."  Adding a "default m &&  
(NFSV4 || NFSD_V4)" or something like that under Kerberos GSS might  
work as well.

But the point is, what I'm removing is not a build dependency; what  
I'm replacing it with is a build dependency.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
