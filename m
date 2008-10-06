From: Chuck Lever <chuck.lever@oracle.com>
Subject: Fwd: [NFS] [patch] rpcgen: include sys/ioctl.h on linux systems
Date: Mon, 6 Oct 2008 14:10:23 -0400
Message-ID: <0E680393-D341-4484-80AB-2723E631F0CC@oracle.com>
References: <200804200649.44542.vapier@gentoo.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: multipart/mixed; boundary=Apple-Mail-2-196287862
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:22815 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754703AbYJFSKs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Oct 2008 14:10:48 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail-2-196287862
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit

Steve-

Resending.  Is this valid for nfs-utils 1.1.4?

Begin forwarded message:

> From: Mike Frysinger <vapier@gentoo.org>
> Date: April 20, 2008 6:49:44 AM GMT-04:00
> To: nfs@lists.sourceforge.net
> Subject: [NFS] [patch] rpcgen: include sys/ioctl.h on linux systems
>
> the rpcgen tool included with nfs-utils will generate calls to  
> ioctl() but not
> actually generate the sys/ioctl.h header include.  attached patch  
> should fix
> this.
> -mike

--Apple-Mail-2-196287862
Content-Disposition: attachment;
	filename=nfs-utils-1.1.2-rpcgen-ioctl.patch
Content-Type: text/x-diff;
	x-unix-mode=0666;
	name="nfs-utils-1.1.2-rpcgen-ioctl.patch"
Content-Transfer-Encoding: 7bit

--- tools/rpcgen/rpc_main.c
+++ tools/rpcgen/rpc_main.c
@@ -548,6 +548,9 @@
 #ifndef linux
 	if( !tirpcflag && inetdflag )
 	  f_print(fout, "#include <sys/ttycom.h>/* TIOCNOTTY */\n");
+#else
+	if( !tirpcflag )
+	  f_print(fout, "#include <sys/ioctl.h>/* TIOCNOTTY */\n");
 #endif
 	if( Cflag && (inetdflag || pmflag ) ) {
 	  f_print(fout, "#ifdef __cplusplus\n");

--Apple-Mail-2-196287862
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit

> -------------------------------------------------------------------------
> This SF.net email is sponsored by the 2008 JavaOne(SM) Conference
> Don't miss this year's exciting event. There's still time to save  
> $100.
> Use priority code J8TL2D2.
> http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone_______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>    http://vger.kernel.org/vger-lists.html#linux-nfs

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




--Apple-Mail-2-196287862--
