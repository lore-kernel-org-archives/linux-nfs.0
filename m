From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/5] NFS: Update help text for CONFIG_NFS_FS
Date: Mon, 04 Feb 2008 19:18:02 -0500
Message-ID: <1202170682.28484.55.camel@heimdal.trondhjem.org>
References: <20080205000421.18602.44285.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@citi.umich.edu, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:48407 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757263AbYBEASJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2008 19:18:09 -0500
In-Reply-To: <20080205000421.18602.44285.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-02-04 at 19:04 -0500, Chuck Lever wrote:
> Refresh the help text for Kconfig items related to the NFS client.  Remove
> obsolete URLs, and make the language consistent among the options.
> 
> Also move the ROOT_NFS config option next to the options related to the NFS
> client.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/Kconfig |  136 ++++++++++++++++++++++++++++++------------------------------
>  1 files changed, 69 insertions(+), 67 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 987b5d7..5c7f6ee 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -1517,10 +1517,6 @@ config UFS_FS
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
> @@ -1560,6 +1556,7 @@ menuconfig NETWORK_FILESYSTEMS
>  	  Say Y here to get to see options for network filesystems and
>  	  filesystem-related networking code, such as NFS daemon and
>  	  RPCSEC security modules.
> +
>  	  This option alone does not add any kernel code.
>  
>  	  If you say N, all options in this submenu will be skipped and
> @@ -1574,44 +1571,35 @@ config NFS_FS
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
> +	  Say Y here if you want to access files residing on other computers
> +	  using the internet standard Network File System protocol.  To

Tsk, tsk.... NFS isn't an internet standard (yet!).

> +	  compile this file system support as a module, choose M here: the
> +	  module will be called nfs.
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
> +	  Below you can select which versions of the NFS protocol are
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
> +	  To configure a system which mounts its root file system via NFS at
> +	  boot time, say Y here, select "Kernel level IP autoconfiguration"
> +	  in the NETWORK menu, and select "Root file system on NFS" below.
> +	  You cannot compile this driver as a module in this case.
>  
> -	  If you don't know what all this is about, say N.
> +	  If unsure, say N.
>  
>  config NFS_V3
>  	bool "Provide NFSv3 client support"
>  	depends on NFS_FS
>  	help
> -	  Say Y here if you want your NFS client to be able to speak version
> -	  3 of the NFS protocol.
> +	  This option enables support for version 3 of the NFS protocol
> +	  (RFC 1813) in the kernel's NFS client.
>  
>  	  If unsure, say Y.
>  
> @@ -1619,9 +1607,21 @@ config NFS_V3_ACL
>  	bool "Provide client support for the NFSv3 ACL protocol extension"
>  	depends on NFS_V3
>  	help
> -	  Implement the NFSv3 ACL protocol extension for manipulating POSIX
> -	  Access Control Lists.  The server should also be compiled with
> -	  the NFSv3 ACL protocol extension; see the CONFIG_NFSD_V3_ACL option.
> +	  Some NFS servers support an auxiliary NFSv3 ACL protocol that
> +	  Sun added to Solaris but never became an official part of the
> +	  NFS version 3 protocol.  This nonstandard side-band protocol
> +	  allows applications on NFS clients to manipulate POSIX Access
> +	  Control Lists on files residing on NFS servers.  NFS servers
> +	  enforce ACLs on local files whether this protocol is available
> +	  or not.
> +
> +	  Say Y here if your NFS server supports the Solaris NFSv3 ACL
> +	  protocol and you want your NFS client to allow applications to
> +	  access and modify ACLs on files on the server.
> +
> +	  Some NFS servers don't support the Solaris NFSv3 ACL protocol.
            ^^^^ Most?
> +	  You can say N here or specify the "noacl" mount option to prevent
> +	  your NFS client from trying to use the NFSv3 ACL protocol.
>  
>  	  If unsure, say N.
>  
> @@ -1630,38 +1630,54 @@ config NFS_V4
>  	depends on NFS_FS && EXPERIMENTAL
>  	select RPCSEC_GSS_KRB5
>  	help
> -	  Say Y here if you want your NFS client to be able to speak the newer
> -	  version 4 of the NFS protocol.
> +	  This option enables support for version 4 of the NFS protocol 
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
>  config NFS_DIRECTIO
>  	bool "Allow direct I/O on NFS files"
>  	depends on NFS_FS
> +	default N

Why? Isn't O_DIRECT pretty much a standard feature that is enabled in
most distros at this time?
IMO we should rather be aiming to phase out NFS_DIRECTIO.

>  	help
> -	  This option enables applications to perform uncached I/O on files
> -	  in NFS file systems using the O_DIRECT open() flag.  When O_DIRECT
> -	  is set for a file, its data is not cached in the system's page
> -	  cache.  Data is moved to and from user-level application buffers
> -	  directly.  Unlike local disk-based file systems, NFS O_DIRECT has
> -	  no alignment restrictions.
> +	  This option enables support for uncached I/O on files accessed
> +	  via an NFS mount point.  Applications request direct I/O by
> +	  setting the O_DIRECT flag when opening a file.
> +
> +	  When direct I/O is requested, the NFS client moves data to and
> +	  from user-level application buffers directly to NFS servers.
> +	  Direct I/O on NFS files does not suffer from any I/O or buffer
> +	  alignment restrictions, as does direct I/O on files that reside
> +	  in local file systems.
> +
> +	  For details, see the open(2) man page.
>  
>  	  Unless your program is designed to use O_DIRECT properly, you are
> -	  much better off allowing the NFS client to manage data caching for
> -	  you.  Misusing O_DIRECT can cause poor server performance or network
> -	  storms.  This kernel build option defaults OFF to avoid exposing
> +	  better off allowing the NFS client to manage data caching for you.
> +	  Misusing O_DIRECT can cause poor server performance or network
> +	  storms.  This kernel build option defaults to N to avoid exposing
>  	  system administrators unwittingly to a potentially hazardous
>  	  feature.
>  
> -	  For more details on NFS O_DIRECT, see fs/nfs/direct.c.
> -
> -	  If unsure, say N.  This reduces the size of the NFS client, and
> -	  causes open() to return EINVAL if a file residing in NFS is
> +	  If unsure, say N.  This reduces the size of the kernel NFS client,
> +	  and causes open(2) to return EINVAL if a file residing in NFS is
>  	  opened with the O_DIRECT flag.
>  
> +config ROOT_NFS
> +	bool "Root file system on NFS"
> +	depends on NFS_FS=y && IP_PNP
> +	help
> +	  If you want your system to mount its root file system via NFS, say
> +	  Y here.  This is common practice for managing systems without
> +	  local permanent storage.  Read <file:Documentation/nfsroot.txt>
> +	  for details.
> +
> +	  Most people say N here.
> +
>  config NFSD
>  	tristate "NFS server support"
>  	depends on INET
> @@ -1738,20 +1754,6 @@ config NFSD_TCP
>  	  TCP connections usually perform better than the default UDP when
>  	  the network is lossy or congested.  If unsure, say Y.
>  
> -config ROOT_NFS
> -	bool "Root file system on NFS"
> -	depends on NFS_FS=y && IP_PNP
> -	help
> -	  If you want your Linux box to mount its whole root file system (the
> -	  one containing the directory /) from some other computer over the
> -	  net via NFS (presumably because your box doesn't have a hard disk),
> -	  say Y. Read <file:Documentation/nfsroot.txt> for details. It is
> -	  likely that in this case, you also want to say Y to "Kernel level IP
> -	  autoconfiguration" so that your box can discover its network address
> -	  at boot time.
> -
> -	  Most people say N here.
> -
>  config LOCKD
>  	tristate
>  
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

