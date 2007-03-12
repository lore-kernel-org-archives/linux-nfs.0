From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nfs-utils patch for mount-reserved-port
Date: Mon, 12 Mar 2007 12:04:17 -0400
Message-ID: <EXNANE01CIqtQvAauNj000000b2@exnane01.hq.netapp.com>
References: <EXNANE01XsNQptgFrYI000000b1@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQn24-0001Ac-Ke
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 09:05:56 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQn25-0001br-D3
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 09:05:57 -0700
Received: from svlexc03.hq.netapp.com (svlexc03.corp.netapp.com
	[10.57.156.149])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l2CG5Y4H017045
	for <nfs@lists.sourceforge.net>; Mon, 12 Mar 2007 09:05:49 -0700 (PDT)
In-Reply-To: <EXNANE01XsNQptgFrYI000000b1@exnane01.hq.netapp.com>
References: <EXNANE01XsNQptgFrYI000000b1@exnane01.hq.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Nobody replied yet, but on a second look, removing the compatibility
for the fd leads directly to removing all sorts of other compatibility stuff
being pitched too. So I think this way is best.

Yes, the second linux version check for <= 66314 technically precludes
the fsock being still -1, but it reads better, and seems a little safer with
the extra fsock check against the uninitialized value.

I am assuming nobody wants to patch util-linux for this kind of thing?
(i.e. that nfs-utils will be shipped configured with --enable-mount in
the future?)

Tom.

At 11:55 AM 3/12/2007, Talpey, Thomas wrote:
>Only create a mount-time reserved port socket for kernels
>which require it (pre-2.1.32/nfs_mount_version 1).
>
>Signed-off-by: Tom Talpey <tmt@netapp.com>
>
>Index: nfs-utils-1.0.12/utils/mount/nfsmount.c
>===================================================================
>--- nfs-utils-1.0.12.orig/utils/mount/nfsmount.c
>+++ nfs-utils-1.0.12/utils/mount/nfsmount.c
>@@ -1120,20 +1120,22 @@ noauth_flavors:
> #endif
>        }
> 
>-       /* create nfs socket for kernel */
>-
>-       if (nfs_pmap->pm_prot == IPPROTO_TCP)
>-               fsock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
>-       else
>-               fsock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
>-       if (fsock < 0) {
>-               perror(_("nfs socket"));
>-               goto fail;
>-       }
>-       if (bindresvport(fsock, 0) < 0) {
>-               perror(_("nfs bindresvport"));
>-               goto fail;
>+       if (nfs_mount_version == 1) {
>+               /* create nfs socket for kernel */
>+               if (nfs_pmap->pm_prot == IPPROTO_TCP)
>+                       fsock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
>+               else
>+                       fsock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
>+               if (fsock < 0) {
>+                       perror(_("nfs socket"));
>+                       goto fail;
>+               }
>+               if (bindresvport(fsock, 0) < 0) {
>+                       perror(_("nfs bindresvport"));
>+                       goto fail;
>+               }
>        }
>+
> #ifdef NFS_MOUNT_DEBUG
>        printf(_("using port %d for nfs deamon\n"), nfs_pmap->pm_port);
> #endif
>@@ -1143,7 +1145,7 @@ noauth_flavors:
>         * to avoid problems with multihomed hosts.
>         * --Swen
>         */
>-       if (linux_version_code() <= 66314
>+       if (linux_version_code() <= 66314 && fsock != -1
>            && connect(fsock, (struct sockaddr *) nfs_saddr,
>                       sizeof (*nfs_saddr)) < 0) {
>                perror(_("nfs connect"));
>
>
>
>-------------------------------------------------------------------------
>Take Surveys. Earn Cash. Influence the Future of IT
>Join SourceForge.net's Techsay panel and you'll get the chance to share your
>opinions on IT & business topics through brief surveys-and earn cash
>http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
