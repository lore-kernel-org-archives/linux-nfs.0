From: "Michael Rayment" <mike@cs.mun.ca>
Subject: Autofs problem while using new nfs-utils package
Date: Sat, 6 Oct 2007 02:19:20 -0230
Message-ID: <200710060219.20536.mike@cs.mun.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ie1bT-0007Ki-3q
	for nfs@lists.sourceforge.net; Fri, 05 Oct 2007 21:49:27 -0700
Received: from mercury.cs.mun.ca ([134.153.48.18])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ie1bX-00011o-47
	for nfs@lists.sourceforge.net; Fri, 05 Oct 2007 21:49:32 -0700
Received: from localhost (localhost.cs.mun.ca [127.0.0.1])
	by localhost.cs.mun.ca (Postfix) with ESMTP id 0BE9E17A943
	for <nfs@lists.sourceforge.net>; Sat,  6 Oct 2007 02:19:21 -0230 (NDT)
Received: from mercury.cs.mun.ca ([127.0.0.1])
	by localhost (mercury.cs.mun.ca [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id m9vYdZ9VGZ0R for <nfs@lists.sourceforge.net>;
	Sat,  6 Oct 2007 02:19:20 -0230 (NDT)
Received: from hogwarts (hogwarts.cs.mun.ca [134.153.49.191])
	by mercury.cs.mun.ca (Postfix) with SMTP id E6E6117A329
	for <nfs@lists.sourceforge.net>; Sat,  6 Oct 2007 02:19:20 -0230 (NDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I just emerged the latest gentoo release of the nfs-utils package, 
nfs-utils-1.1.0-r1.ebuild.  I found that the autofs code did not work for my 
diskless computers that have a readonly /etc directory with a /etc/mtab 
symbolically linked to /proc/mounts.  This was because the creation of the 
mtab lock file /etc/mtab~nnnn failed.  I noticed that in the update_mtab() 
function, a check was put in to acertain whether this situation existed and 
silently carried on whereas the add_mtab() function did not perform the check 
and consequently failed.  My simple minded fix was to add the the same check 
to add_mtab() as can be seen in the context diff below.  Automounting worked 
fine after the fix was applied.   Hopefully some fix will make its way into 
the authoratative release so that I do not have to patch my code locally.

Thanks,

Michael Rayment


*** utils/mount/mount.c.sav     Sat Oct  6 01:52:21 2007
--- utils/mount/mount.c Sat Oct  6 01:55:25 2007
***************
*** 181,188 ****
--- 181,191 ----
                update_mtab(ment.mnt_dir, &ment);
                return 0;
        }

+       if (mtab_does_not_exist() || !mtab_is_writable())
+               return 0;
+
        lock_mtab();

          if ((mtab = setmntent(MOUNTED, "a+")) == NULL) {
                fprintf(stderr, "Can't open " MOUNTED);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
