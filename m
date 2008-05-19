From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/8] NFS: Update help text for CONFIG_NFS_FS
Date: Mon, 19 May 2008 12:44:05 -0400
Message-ID: <8402238E-E8C9-4BE0-9383-032FA7C044F0@oracle.com>
References: <20080518021241.8366.12464.stgit@ellison.1015granger.net> <20080518021614.8366.39102.stgit@ellison.1015granger.net> <20080519162456.GK7622@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:54683 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbYESQon (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2008 12:44:43 -0400
In-Reply-To: <20080519162456.GK7622@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 19, 2008, at 12:24 PM, J. Bruce Fields wrote:
> On Sat, May 17, 2008 at 10:16:14PM -0400, Chuck Lever wrote:
>> Clean up: refresh the help text for Kconfig items related to the NFS
>> client.  Remove obsolete URLs, and make the language consistent among
>> the options.
>>
>> Also move the ROOT_NFS config option next to the options related to  
>> the
>> NFS client.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/Kconfig |  115 +++++++++++++++++++++++++++++ 
>> +------------------------------
>> 1 files changed, 57 insertions(+), 58 deletions(-)
>>
>>
>> diff --git a/fs/Kconfig b/fs/Kconfig
>> index cf12c40..0e0faf2 100644
>> --- a/fs/Kconfig
>> +++ b/fs/Kconfig
>> @@ -1595,76 +1592,92 @@ menuconfig NETWORK_FILESYSTEMS
>> if NETWORK_FILESYSTEMS
>>
>> config NFS_FS
>> -	tristate "NFS file system support"
>> +	tristate "NFS client support"
>> 	depends on INET
>> 	select LOCKD
>> 	select SUNRPC
>> 	select NFS_ACL_SUPPORT if NFS_V3_ACL
>> 	help
>> -	  If you are connected to some other (usually local) Unix computer
>> -	  (using SLIP, PLIP, PPP or Ethernet) and want to mount files  
>> residing
>> -	  on that computer (the NFS server) using the Network File Sharing
>> -	  protocol, say Y. "Mounting files" means that the client can  
>> access
>> -	  the files with usual UNIX commands as if they were sitting on the
>> -	  client's hard disk. For this to work, the server must run the
>> -	  programs nfsd and mountd (but does not need to have NFS file  
>> system
>> -	  support enabled in its kernel). NFS is explained in the Network
>> -	  Administrator's Guide, available from
>> -	  <http://www.tldp.org/docs.html#guide>, on its man page: "man
>> -	  nfs", and in the NFS-HOWTO.
>> -
>> -	  A superior but less widely used alternative to NFS is provided by
>> -	  the Coda file system; see "Coda file system support" below.
>> +	  Choose Y here if you want to access files residing on other
>> +	  computers using Sun's Network File System protocol.  To compile
>> +	  this file system support as a module, choose M here: the module
>> +	  will be called nfs.
>>
>> -	  If you say Y here, you should have said Y to TCP/IP networking  
>> also.
>> -	  This option would enlarge your kernel by about 27 KB.
>> +	  To mount file systems exported by NFS servers, you also need to
>> +	  install the user space mount.nfs command which can be found in
>> +	  the Linux nfs-utils package, available from http://linux- 
>> nfs.org/.
>> +	  Information about using the mount command is available in the
>> +	  mount(8) man page.  More detail about the Linux NFS client
>> +	  implementation is available via the nfs(5) man page.
>>
>> -	  To compile this file system support as a module, choose M here:  
>> the
>> -	  module will be called nfs.
>> +	  Below you can choose which versions of the NFS protocol are
>> +	  available in the kernel to mount NFS servers.  Support for NFS
>> +	  version 2 (RFC 1094) is always available when NFS_FS is selected.
>>
>> -	  If you are configuring a diskless machine which will mount its  
>> root
>> -	  file system over NFS at boot time, say Y here and to "Kernel
>> -	  level IP autoconfiguration" above and to "Root file system on  
>> NFS"
>> -	  below. You cannot compile this driver as a module in this case.
>> -	  There are two packages designed for booting diskless machines  
>> over
>> -	  the net: netboot, available from
>> -	  <http://ftp1.sourceforge.net/netboot/>, and Etherboot,
>> -	  available from <http://ftp1.sourceforge.net/etherboot/>.
>> +	  To configure a system which mounts its root file system via NFS
>> +	  at boot time, say Y here, select "Kernel level IP
>> +	  autoconfiguration" in the NETWORK menu, and select "Root file
>> +	  system on NFS" below.  You cannot compile this file system as a
>> +	  module in this case.
>>
>> -	  If you don't know what all this is about, say N.
>> +	  If unsure, say N.
>>
>> config NFS_V3
>> -	bool "Provide NFSv3 client support"
>> +	bool "NFS client support for NFS version 3"
>> 	depends on NFS_FS
>> 	help
>> -	  Say Y here if you want your NFS client to be able to speak  
>> version
>> -	  3 of the NFS protocol.
>> +	  This option enables support for version 3 of the NFS protocol
>> +	  (RFC 1813) in the kernel's NFS client.
>>
>> 	  If unsure, say Y.
>>
>> config NFS_V3_ACL
>> -	bool "Provide client support for the NFSv3 ACL protocol extension"
>> +	bool "NFS client support for the NFSv3 ACL protocol extension"
>> 	depends on NFS_V3
>> 	help
>> -	  Implement the NFSv3 ACL protocol extension for manipulating POSIX
>> -	  Access Control Lists.  The server should also be compiled with
>> -	  the NFSv3 ACL protocol extension; see the CONFIG_NFSD_V3_ACL  
>> option.
>> +	  Some NFS servers support an auxiliary NFSv3 ACL protocol that
>> +	  Sun added to Solaris but never became an official part of the
>> +	  NFS version 3 protocol.  This protocol extension allows
>> +	  applications on NFS clients to manipulate POSIX Access Control
>> +	  Lists on files residing on NFS servers.  NFS servers enforce
>> +	  ACLs on local files whether this protocol is available or not.
>> +
>> +	  Choose Y here if your NFS server supports the Solaris NFSv3 ACL
>> +	  protocol extension and you want your NFS client to allow
>> +	  applications to access and modify ACLs on files on the server.
>> +
>> +	  Most NFS servers don't support the Solaris NFSv3 ACL protocol
>> +	  extension.  You can choose N here or specify the "noacl" mount
>> +	  option to prevent your NFS client from trying to use the NFSv3
>> +	  ACL protocol.
>>
>> 	  If unsure, say N.
>>
>> config NFS_V4
>> -	bool "Provide NFSv4 client support (EXPERIMENTAL)"
>> +	bool "NFS client support for NFS version 4 (EXPERIMENTAL)"
>> 	depends on NFS_FS && EXPERIMENTAL
>> 	select RPCSEC_GSS_KRB5
>> 	help
>> -	  Say Y here if you want your NFS client to be able to speak the  
>> newer
>> -	  version 4 of the NFS protocol.
>> +	  This option enables support for version 4 of the NFS protocol
>
> By the way, this triggers a "trailing whitespace" complaint.


Weird.  I did run this by checkpatch.pl and I didn't see any warnings.

Trond, let me know if you want me to resubmit.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
