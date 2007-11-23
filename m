From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] nfs-utils crossmnt/fsid bug
Date: Fri, 23 Nov 2007 13:50:29 +1100
Message-ID: <18246.16373.177320.570040@notabene.brown>
References: <20070905204628.GD29582@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IvOcl-0002mV-Ty
	for nfs@lists.sourceforge.net; Thu, 22 Nov 2007 18:50:36 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IvOcq-0005MZ-Gs
	for nfs@lists.sourceforge.net; Thu, 22 Nov 2007 18:50:42 -0800
In-Reply-To: message from J. Bruce Fields on Wednesday September 5
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wednesday September 5, bfields@fieldses.org wrote:
> With an exports entry like
> 
> 	/exports *.citi.umich.edu(rw,crossmnt,fsid=0)
> 
> and some other stuff mounted under /exports, I get an odd situation
> where listing /exports/submnt/ shows me the contents of /exports/.
> 
> I looks to me like what's happening is that the new code to
> automatically export filesystems under crossmnt exports is exporting
> those directories with the fsid option turned on, with the result that
> the root of each of those subdirectories ends up with the same
> filehandle as the root of /exports, and the hilarity ensues.  But I
> haven't tried a patch yet.
> 
> Does that make sense?  I assume we should just clear the fsid flag on
> submounts, as it's never going to make sense, and leave the logic
> otherwise intact.
> 
> --b.

Thanks for noticing and reporting this.

Does this (untested, but it compiles) patch seem right?

NeilBrown

--------
When exported a filesystems with option inherited (by the crossmnt
option) from a higherlevel filesystem, ignore filesystem specific
options like FSID and explicit UUID.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index fd317cd..ff56b9f 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -565,20 +565,29 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
 	qword_print(f, path);
 	qword_printint(f, time(0)+30*60);
 	if (exp) {
-		qword_printint(f, exp->e_flags);
+		int different_fs = 0;
+		struct stat stb1, stb2;
+		if (stat(path, &stb1) == 0 &&
+		    stat(exp->e_path, &stb2) == 0 &&
+		    stb1.st_dev != stb2.st_dev)
+			different_fs = 1;
+		if (different_fs)
+			qword_printint(f, exp->e_flags & ~NFSEXP_FSID);
+		else
+			qword_printint(f, exp->e_flags);
 		qword_printint(f, exp->e_anonuid);
 		qword_printint(f, exp->e_anongid);
 		qword_printint(f, exp->e_fsid);
 		write_fsloc(f, exp, path);
 		write_secinfo(f, exp);
 #if USE_BLKID
- 		if (exp->e_uuid == NULL) {
+ 		if (exp->e_uuid == NULL || different_fs) {
  			char u[16];
  			if (get_uuid(path, NULL, 16, u)) {
  				qword_print(f, "uuid");
  				qword_printhex(f, u, 16);
  			}
- 		} else if (exp->e_uuid) {
+ 		} else {
  			qword_print(f, "uuid");
  			qword_printhex(f, exp->e_uuid, 16);
  		}

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

