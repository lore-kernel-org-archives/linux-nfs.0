From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 16] knfsd: nfsd: oops exporting nonexistent directory
Date: Mon, 3 Apr 2006 15:18:28 +1000
Message-ID: <1060403051828.1785@suse.de>
References: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FQHUA-0005TK-Lp
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:20:18 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FQHU9-0008If-2w
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:20:18 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



Export a directory that does not exist:
	exportfs -orw,fsid=0,insecure,no_subtree_check client:/home/NFS4

Try to mount from client with nfs4. Mount hangs (I'm not sure why -
that's another issue).

While client is hung, back on server

	mkdir /home/NFS4

The server panics in dput. I traced the problem back to svc_export_parse()
calling path_release() even though path_lookup() failed (it happens
to fill in the nameidata structure with a negative dentry - so the test
after out: succeeds).

After patching, an recreating the problem, the client mount still takes
some time before finally exiting with a message "couldn't read
superblock".

Here is a simple patch to resolve this issue:

Signed-Off-By: Frank Filz <ffilzlnx@us.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2006-04-03 15:12:08.000000000 +1000
+++ ./fs/nfsd/export.c	2006-04-03 15:12:08.000000000 +1000
@@ -422,7 +422,7 @@ static int svc_export_parse(struct cache
 	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) <= 0)
 		goto out;
 	err = path_lookup(buf, 0, &nd);
-	if (err) goto out;
+	if (err) goto out_no_path;
 
 	exp.h.flags = 0;
 	exp.ex_client = dom;
@@ -475,6 +475,7 @@ static int svc_export_parse(struct cache
  out:
 	if (nd.dentry)
 		path_release(&nd);
+ out_no_path:
 	if (dom)
 		auth_domain_put(dom);
 	kfree(buf);


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
