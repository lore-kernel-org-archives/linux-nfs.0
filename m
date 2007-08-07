From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 10/10] mount.nfs: Fix background mounts
Date: Tue, 7 Aug 2007 10:00:01 +1000
Message-ID: <18103.46593.586196.718154@notabene.brown>
References: <20070803172415.3357.91411.stgit@monet.1015granger.net>
	<20070806223152.GA7917@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IICUb-0001g3-Bc
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 17:00:12 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IICUd-0000dc-6v
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 17:00:13 -0700
In-Reply-To: message from Steinar H. Gunderson on Tuesday August 7
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

On Tuesday August 7, sgunderson@bigfoot.com wrote:
> On Fri, Aug 03, 2007 at 01:24:15PM -0400, Chuck Lever wrote:
> > The new mount.nfs helper does not support background mounts.  Add support
> > for background mounts.
> 
> I've now pushed the current git (which includes these patches) into Debian,
> which will hopefully give us some experience with "bg" again. It seems to
> have fixed some bugs of the old bg implementation, but this one still
> remains:
> 
>   http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=144185
> 
> Any chance mount.nfs could simply ignore HUPs?
> 
> /* Steinar */
> -- 
> Homepage: http://www.sesse.net/

Something like this?  Anyone want to test it?

NeilBrown


diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index a232519..5769cd2 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -530,9 +530,7 @@ int main(int argc, char *argv[])
 		 * Parent exits immediately with success.  Make
 		 * sure not to free "mount_point"
 		 */
-		if (fork() > 0)
-			exit(0);
-
+		daemon(0,0);
 		mnt_err = try_mount(spec, mount_point, flags, fs_type,
 					&extra_opts, mount_opts, fake,
 					nomtab, BACKGROUND);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
