From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/5] NFSD: Update help text for CONFIG_NFSD
Date: Mon, 4 Feb 2008 21:32:51 -0500
Message-ID: <BED9361E-F850-493F-9612-8682CF06C932@oracle.com>
References: <20080205000428.18602.37168.stgit@manray.1015granger.net> <20080205002254.GI32086@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:11046 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754103AbYBECdb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2008 21:33:31 -0500
In-Reply-To: <20080205002254.GI32086@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 4, 2008, at 7:22 PM, J. Bruce Fields wrote:
> On Mon, Feb 04, 2008 at 07:04:28PM -0500, Chuck Lever wrote:
>> Refresh the help text for Kconfig items related to the NFS  
>> server.  Remove
>> obsolete URLs, and make the language consistent among the options.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>>  fs/Kconfig |   70 +++++++++++++++++++++++++++++++++++++ 
>> +----------------------
>>  1 files changed, 44 insertions(+), 26 deletions(-)
>>
>> diff --git a/fs/Kconfig b/fs/Kconfig
>> index 5c7f6ee..9363211 100644
>> --- a/fs/Kconfig
>> +++ b/fs/Kconfig
>> @@ -1693,27 +1693,26 @@ config NFSD
>>  	select PROC_FS if NFSD_V4
>>  	select PROC_FS if SUNRPC_GSS
>>  	help
>> -	  If you want your Linux box to act as an NFS *server*, so that  
>> other
>> -	  computers on your local network which support NFS can access  
>> certain
>> -	  directories on your box transparently, you have two options:  
>> you can
>> -	  use the self-contained user space program nfsd, in which case you
>> -	  should say N here, or you can say Y and use the kernel based NFS
>> -	  server. The advantage of the kernel based solution is that it is
>> -	  faster.
>> +	  Say Y here if you want to allow other computers to access files
>> +	  residing on this system using the internet standard Network File
>> +	  System protocol.  To compile the NFS server support as a module,
>> +	  choose M here: the module will be called nfsd.
>>
>> -	  In either case, you will need support software; the respective
>> -	  locations are given in the file <file:Documentation/Changes>  
>> in the
>> -	  NFS section.
>> +	  You may choose to use a user-space NFS server instead, in which
>> +	  case you can say N here.
>>
>> -	  If you say Y here, you will get support for version 2 of the NFS
>> -	  protocol (NFSv2). If you also want NFSv3, say Y to the next  
>> question
>> -	  as well.
>> +	  To export local file systems using NFS, you also need to install
>> +	  user space programs which can be found in the Linux nfs-utils
>> +	  package, available from http://linux-nfs.org/.  More detail about
>> +	  the Linux NFS server implementation is available via the
>> +	  exports(5) man page.
>>
>> -	  Please read the NFS-HOWTO, available from
>> -	  <http://www.tldp.org/docs.html#howto>.
>> +	  Below you can select which versions of the NFS protocol are
>> +	  available to clients mounting the NFS server on this system.
>> +	  Support for NFS version 2 (RFC 1094) is always available when
>> +	  CONFIG_NFSD is selected.
>>
>> -	  To compile the NFS server support as a module, choose M here: the
>> -	  module will be called nfsd.  If unsure, say N.
>> +	  If unsure, say N.
>>
>>  config NFSD_V2_ACL
>>  	bool
>> @@ -1723,26 +1722,45 @@ config NFSD_V3
>>  	bool "Provide NFSv3 server support"
>>  	depends on NFSD
>>  	help
>> -	  If you would like to include the NFSv3 server as well as the  
>> NFSv2
>> -	  server, say Y here.  If unsure, say Y.
>> +	  This option enables support in your system's NFS server for
>> +	  version 3 of the NFS protocol (RFC 1813).
>> +
>> +	  If unsure, say Y.
>>
>>  config NFSD_V3_ACL
>>  	bool "Provide server support for the NFSv3 ACL protocol extension"
>>  	depends on NFSD_V3
>>  	help
>> -	  Implement the NFSv3 ACL protocol extension for manipulating POSIX
>> -	  Access Control Lists on exported file systems. NFS clients should
>> -	  be compiled with the NFSv3 ACL protocol extension; see the
>> -	  CONFIG_NFS_V3_ACL option.  If unsure, say N.
>> +	  Solaris NFS servers support an auxiliary NFSv3 ACL protocol that
>> +	  never became an official part of the NFS version 3 protocol.
>> +	  This nonstandard side-band protocol allows applications on NFS
>
> I'd leave out "nonstandard" and "side-band", as they repeat what you
> said more carefully in the previous sentence.  (Ditto for the
> client-side text.)
>
>> +	  clients to manipulate POSIX Access Control Lists on files
>> +	  residing on NFS servers.  NFS servers enforce POSIX ACLs on
>> +	  local files whether this protocol is available or not
>
> Missing period.
>
> Seems OK, though, on a quick skim.  Thanks.--b.

OK, fixed up.  Thanks for the review!

>
>> +
>> +	  This option enables support in your system's NFS server for the
>> +	  NFSv3 ACL protocol extension allowing NFS clients to manipulate
>> +	  POSIX ACLs on files exported by your system's NFS server.  NFS
>> +	  clients which support the Solaris NFSv3 ACL protocol can then
>> +	  access and modify ACLs on your NFS server.
>> +
>> +	  To store ACLs on your NFS server, you also need to enable ACL-
>> +	  related CONFIG options for your local file systems of choice.
>> +
>> +	  If unsure, say N.
>>
>>  config NFSD_V4
>>  	bool "Provide NFSv4 server support (EXPERIMENTAL)"
>>  	depends on NFSD && NFSD_V3 && EXPERIMENTAL
>>  	select RPCSEC_GSS_KRB5
>>  	help
>> -	  If you would like to include the NFSv4 server as well as the  
>> NFSv2
>> -	  and NFSv3 servers, say Y here.  This feature is experimental, and
>> -	  should only be used if you are interested in helping to test  
>> NFSv4.
>> +	  This option enables support in your system's NFS server for
>> +	  version 4 of the NFS protocol (RFC 3530).
>> +
>> +	  To export files using NFSv4, you need to install additional user
>> +	  space programs which can be found in the Linux nfs-utils package,
>> +	  available from http://linux-nfs.org/.
>> +
>>  	  If unsure, say N.
>>
>>  config NFSD_TCP
>>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



