From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 06/11] nfs-utils: mount:  AUTH_NONE mounts
Date: Fri, 2 Mar 2007 15:01:22 +1100
Message-ID: <17895.41362.382320.934994@notabene.brown>
References: <45E2C1FD.7000506@RedHat.com>
	<17891.52293.103984.465480@notabene.brown>
	<45E43C92.6090805@redhat.com>
	<17894.2913.850879.838771@notabene.brown>
	<45E6FB0B.7000204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HMyya-0008G7-Om
	for nfs@lists.sourceforge.net; Thu, 01 Mar 2007 20:02:38 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HMyyc-0007Fa-BA
	for nfs@lists.sourceforge.net; Thu, 01 Mar 2007 20:02:38 -0800
In-Reply-To: message from Peter Staubach on Thursday March 1
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

On Thursday March 1, staubach@redhat.com wrote:
> 
> This was used to address RH bz187370.

Thanks for the link.  It provides good context.

I would have thought the appropriate response would have been the
following patch, and a suggestion to use
  mount -o sec=none .....
to mount the filesystem.
Do you see a problem with that?

NeilBrown

--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -638,7 +638,9 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 				if (nfs_mount_version < 5) {
 					printf(_("Warning: ignoring sec=%s option\n"), secflavor);
 					continue;
-				} else if (!strcmp(secflavor, "sys"))
+				} else if (!strcmp(secflavor, "none"))
+					data->pseudoflavor = AUTH_NONE;
+				else if (!strcmp(secflavor, "sys"))
 					data->pseudoflavor = AUTH_SYS;
 				else if (!strcmp(secflavor, "krb5"))
 					data->pseudoflavor = AUTH_GSS_KRB5;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
