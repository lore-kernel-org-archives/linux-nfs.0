From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/8] NFS: Update help text for CONFIG_NFS_FS
Date: Mon, 19 May 2008 12:24:56 -0400
Message-ID: <20080519162456.GK7622@fieldses.org>
References: <20080518021241.8366.12464.stgit@ellison.1015granger.net> <20080518021614.8366.39102.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45667 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735AbYESQZO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 12:25:14 -0400
In-Reply-To: <20080518021614.8366.39102.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 17, 2008 at 10:16:14PM -0400, Chuck Lever wrote:
> Clean up: refresh the help text for Kconfig items related to the NFS
> client.  Remove obsolete URLs, and make the language consistent among
> the options.
> 
> Also move the ROOT_NFS config option next to the options related to the
> NFS client.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/Kconfig |  115 ++++++++++++++++++++++++++++++------------------------------
>  1 files changed, 57 insertions(+), 58 deletions(-)
> 
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index cf12c40..0e0faf2 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -1544,10 +1544,6 @@ config UFS_FS
>            The recently released UFS2 variant (used in FreeBSD 5.x) is
>            READ-ONLY supported.
>  
> -	  If you only intend to mount files from some other Unix over the
> -	  network using NFS, you don't need the UFS file system support (but
> -	  you need NFS file system support obviously).
> -
>  	  Note that this option is generally not needed for floppies, since a
>  	  good portable way to transport files and directories between unixes
>  	  (and even other operating systems) is given by the tar program ("man
> @@ -1587,6 +1583,7 @@ menuconfig NETWORK_FILESYSTEMS
>  	  Say Y here to get to see options for network filesystems and
>  	  filesystem-related networking code, such as NFS daemon and
>  	  RPCSEC security modules.
> +
>  	  This option alone does not add any kernel code.
>  
>  	  If you say N, all options in this submenu will be skipped and
> @@ -1595,76 +1592,92 @@ menuconfig NETWORK_FILESYSTEMS
>  if NETWORK_FILESYSTEMS
>  
>  config NFS_FS
> -	tristate "NFS file system support"
> +	tristate "NFS client support"
>  	depends on INET
>  	select LOCKD
>  	select SUNRPC
>  	select NFS_ACL_SUPPORT if NFS_V3_ACL
>  	help
> -	  If you are connected to some other (usually local) Unix computer
> -	  (using SLIP, PLIP, PPP or Ethernet) and want to mount files residing
> -	  on that computer (the NFS server) using the Network File Sharing
> -	  protocol, say Y. "Mounting files" means that the client can access
> -	  the files with usual UNIX commands as if they were sitting on the
> -	  client's hard disk. For this to work, the server must run the
> -	  programs nfsd and mountd (but does not need to have NFS file system
> -	  support enabled in its kernel). NFS is explained in the Network
> -	  Administrator's Guide, available from
> -	  <http://www.tldp.org/docs.html#guide>, on its man page: "man
> -	  nfs", and in the NFS-HOWTO.
> -
> -	  A superior but less widely used alternative to NFS is provided by
> -	  the Coda file system; see "Coda file system support" below.
> +	  Choose Y here if you want to access files residing on other
> +	  computers using Sun's Network File System protocol.  To compile
> +	  this file system support as a module, choose M here: the module
> +	  will be called nfs.
>  
> -	  If you say Y here, you should have said Y to TCP/IP networking also.
> -	  This option would enlarge your kernel by about 27 KB.
> +	  To mount file systems exported by NFS servers, you also need to
> +	  install the user space mount.nfs command which can be found in
> +	  the Linux nfs-utils package, available from http://linux-nfs.org/.
> +	  Information about using the mount command is available in the
> +	  mount(8) man page.  More detail about the Linux NFS client
> +	  implementation is available via the nfs(5) man page.
>  
> -	  To compile this file system support as a module, choose M here: the
> -	  module will be called nfs.
> +	  Below you can choose which versions of the NFS protocol are
> +	  available in the kernel to mount NFS servers.  Support for NFS
> +	  version 2 (RFC 1094) is always available when NFS_FS is selected.
>  
> -	  If you are configuring a diskless machine which will mount its root
> -	  file system over NFS at boot time, say Y here and to "Kernel
> -	  level IP autoconfiguration" above and to "Root file system on NFS"
> -	  below. You cannot compile this driver as a module in this case.
> -	  There are two packages designed for booting diskless machines over
> -	  the net: netboot, available from
> -	  <http://ftp1.sourceforge.net/netboot/>, and Etherboot,
> -	  available from <http://ftp1.sourceforge.net/etherboot/>.
> +	  To configure a system which mounts its root file system via NFS
> +	  at boot time, say Y here, select "Kernel level IP
> +	  autoconfiguration" in the NETWORK menu, and select "Root file
> +	  system on NFS" below.  You cannot compile this file system as a
> +	  module in this case.
>  
> -	  If you don't know what all this is about, say N.
> +	  If unsure, say N.
>  
>  config NFS_V3
> -	bool "Provide NFSv3 client support"
> +	bool "NFS client support for NFS version 3"
>  	depends on NFS_FS
>  	help
> -	  Say Y here if you want your NFS client to be able to speak version
> -	  3 of the NFS protocol.
> +	  This option enables support for version 3 of the NFS protocol
> +	  (RFC 1813) in the kernel's NFS client.
>  
>  	  If unsure, say Y.
>  
>  config NFS_V3_ACL
> -	bool "Provide client support for the NFSv3 ACL protocol extension"
> +	bool "NFS client support for the NFSv3 ACL protocol extension"
>  	depends on NFS_V3
>  	help
> -	  Implement the NFSv3 ACL protocol extension for manipulating POSIX
> -	  Access Control Lists.  The server should also be compiled with
> -	  the NFSv3 ACL protocol extension; see the CONFIG_NFSD_V3_ACL option.
> +	  Some NFS servers support an auxiliary NFSv3 ACL protocol that
> +	  Sun added to Solaris but never became an official part of the
> +	  NFS version 3 protocol.  This protocol extension allows
> +	  applications on NFS clients to manipulate POSIX Access Control
> +	  Lists on files residing on NFS servers.  NFS servers enforce
> +	  ACLs on local files whether this protocol is available or not.
> +
> +	  Choose Y here if your NFS server supports the Solaris NFSv3 ACL
> +	  protocol extension and you want your NFS client to allow
> +	  applications to access and modify ACLs on files on the server.
> +
> +	  Most NFS servers don't support the Solaris NFSv3 ACL protocol
> +	  extension.  You can choose N here or specify the "noacl" mount
> +	  option to prevent your NFS client from trying to use the NFSv3
> +	  ACL protocol.
>  
>  	  If unsure, say N.
>  
>  config NFS_V4
> -	bool "Provide NFSv4 client support (EXPERIMENTAL)"
> +	bool "NFS client support for NFS version 4 (EXPERIMENTAL)"
>  	depends on NFS_FS && EXPERIMENTAL
>  	select RPCSEC_GSS_KRB5
>  	help
> -	  Say Y here if you want your NFS client to be able to speak the newer
> -	  version 4 of the NFS protocol.
> +	  This option enables support for version 4 of the NFS protocol 

By the way, this triggers a "trailing whitespace" complaint.

--b.

> +	  (RFC 3530) in the kernel's NFS client.
>  
> -	  Note: Requires auxiliary userspace daemons which may be found on
> -		http://www.citi.umich.edu/projects/nfsv4/
> +	  To mount NFS servers using NFSv4, you also need to install user
> +	  space programs which can be found in the Linux nfs-utils package,
> +	  available from http://linux-nfs.org/.
>  
>  	  If unsure, say N.
>  
> +config ROOT_NFS
> +	bool "Root file system on NFS"
> +	depends on NFS_FS=y && IP_PNP
> +	help
> +	  If you want your system to mount its root file system via NFS,
> +	  choose Y here.  This is common practice for managing systems
> +	  without local permanent storage.  For details, read
> +	  <file:Documentation/filesystems/nfsroot.txt>.
> +
> +	  Most people say N here.
> +
>  config NFSD
>  	tristate "NFS server support"
>  	depends on INET
> @@ -1746,20 +1759,6 @@ config NFSD_V4
>  
>  	  If unsure, say N.
>  
> -config ROOT_NFS
> -	bool "Root file system on NFS"
> -	depends on NFS_FS=y && IP_PNP
> -	help
> -	  If you want your Linux box to mount its whole root file system (the
> -	  one containing the directory /) from some other computer over the
> -	  net via NFS (presumably because your box doesn't have a hard disk),
> -	  say Y. Read <file:Documentation/filesystems/nfsroot.txt> for
> -	  details. It is likely that in this case, you also want to say Y to
> -	  "Kernel level IP autoconfiguration" so that your box can discover
> -	  its network address at boot time.
> -
> -	  Most people say N here.
> -
>  config LOCKD
>  	tristate
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
