From: "David Mathog" <mathog-7GExONQZ6ZKVc3sceRu5cw@public.gmane.org>
Subject: nfs-utils, umount -l, and unmount requests
Date: Wed, 19 Nov 2008 15:54:42 -0800
Message-ID: <E1L2wsc-0004Rs-2I@mendel.bio.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mendel.bio.caltech.edu ([131.215.12.38]:34247 "EHLO
	mendel.bio.caltech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025AbYKTAYH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Nov 2008 19:24:07 -0500
Received: from nobody by mendel.bio.caltech.edu with local (Exim 4.69)
	(envelope-from <mathog-7GExONQZ6ZKVc3sceRu5cw@public.gmane.org>)
	id 1L2wsc-0004Rs-2I
	for linux-nfs@vger.kernel.org; Wed, 19 Nov 2008 15:54:42 -0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[I hope this is the right place to send this.  I tried 
agud@redhat.com, who is listed on the relevant file's copyright,
but that mailbox was disabled.]


This concerns nfsmount.c in nfs-utils-1.1.4.

I spent most of today trying to figure out why after upgrading an NFS
client machine from Mandriva 2007.1 to 2008.1 suddenly the NFS server
stopped logging  "authenticated unmount request" messages when the
client rebooted.  It turned out this was a consequence of the umount
"-l" flag, which is used in the shutdown scripts and the many recent
changes in the organization of the umount commands.  Long story short,
under Mandriva 2007.1 umount looked for umount.nfs, which was not
present in that release, and then went on to send the unmount request
itself.  On Mandriva 2008.1, where umount.nfs is present, the ball
was passed to this program, which promptly dropped it if "-l" had been
specified.  The NFS directory was unmounted correctly, but the "unmount
request" was never sent. 

I traced this issue down to these lines of code in nfsumount.c,
starting at line 351 (some may wrap):

	if (mc) {
		if (!lazy && strcmp(mc->m.mnt_type, "nfs4") != 0)
			/* We ignore the error from do_nfs_umount23.
			 * If the actual umount succeeds (in del_mtab),
			 * we don't want to signal an error, as that
			 * could cause /sbin/mount to retry!
			 */
			do_nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);
	} else if (*spec != '/') {
		if (!lazy)
			ret = do_nfs_umount23(spec, "tcp,v3");
	} else
		ret = del_mtab(NULL, spec);
	return ret;

Removing the first "!lazy &&" resolved my immediate problem.  What I
don't understand is why it, and the latter "!lazy", were there in
the first place.  The do_nfs_umount23() routine seems to be relatively
harmless, it either sends the message or it doesn't, but either way it
doesn't seem to do anything to the mount information on the local node.
So why is it not run if "-l" (lazy) is set?

Thanks,

David Mathog
mathog-7GExONQZ6ZKVc3sceRu5cw@public.gmane.org
Manager, Sequence Analysis Facility, Biology Division, Caltech

