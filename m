From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] fix NFS mount.nfs options v4
Date: Fri, 28 Jul 2006 12:57:30 -0400
Message-ID: <44CA41FA.5060804@redhat.com>
References: <44CA32CE.9030205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6Vem-0008TH-SF
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 09:57:57 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G6Vel-0008CT-Sa
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 09:57:49 -0700
To: Amit Gud <agud@redhat.com>
In-Reply-To: <44CA32CE.9030205@redhat.com>
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

Amit Gud wrote:

>
> AG
>
>------------------------------------------------------------------------
>
>If the 'user' or 'users' mount option is specified on commandline, verify with 
>/etc/fstab if it is really specified. Setuid bit is still ON and should remain
>ON since mount drops the root privileges.
>
>I've given this patch a good hammering, but not exhaustive by any means.
>
>Signed-off-by: Amit Gud <agud@redhat.com>
>Signed-off-by: Steve Dickson <steved@redhat.com>
>
>---
>
>
>diff -uprN -X ../dontdiff nfs-utils/utils/mount/mount.c nfs-utils-ag/utils/mount/mount.c
>--- nfs-utils/utils/mount/mount.c	2006-07-25 11:07:14.000000000 -0400
>+++ nfs-utils-ag/utils/mount/mount.c	2006-07-28 10:19:54.000000000 -0400
>@@ -355,9 +433,33 @@ int main(int argc, char *argv[])
> 
> 	spec = argv[1];
> 	mount_point = canonicalize(argv[2]);
>-	
>+
> 	parse_opts(mount_opts, &flags, &extra_opts);
> 
>+	if (uid != 0 && !(flags & MS_USERS) && !(flags & MS_USER)) {
>+		fprintf(stderr, "%s: permission denied\n", progname);
>+		exit(1);
>+	}
>+
>+	if ((flags & MS_USER || flags & MS_USERS) && uid != 0) {
>+		/* check if fstab has entry, and further see if the user or users option is given */
>+		if ((mc = getfsspec(spec)) == NULL &&
>+		    (mc = getfsfile(spec)) == NULL) {
>+			fprintf(stderr, "%s: permission denied - invalid option\n", progname);
>+			exit(1);
>+		}
>+		else {
>+			if((flags & MS_USER) && !contains(mc->m.mnt_opts, "user")) {
>+				fprintf(stderr, "%s: permission denied - invalid option\n", progname);
>+				exit(1);
>+			}
>+			if((flags & MS_USERS) && !contains(mc->m.mnt_opts, "users")) {
>+				fprintf(stderr, "%s: permission denied - invalid option\n", progname);
>+				exit(1);
>+			}
>+		}
>+	}
>+
> 	if (!strcmp(progname, "mount.nfs4") || nfs_mount_vers == 4) {
> 		nfs_mount_vers = 4;
> 		mnt_err = nfs4mount(spec, mount_point, &flags, &extra_opts, &mount_opts, 0);
>  
>

It seems to me that these two "permission denied" messages may be somewhat
less than completely helpful.  Would it be possible to be a little more
explicit about why permission was being denied?

    Thanx...

       ps

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
