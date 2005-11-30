From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS cache consistancy appears to be broken...
Date: Wed, 30 Nov 2005 09:25:33 -0500
Message-ID: <438DB65D.8010306@RedHat.com>
References: <200510281607.j9SG7Tll024133@hera.kernel.org>	 <438D0E80.2020905@RedHat.com> <1133334608.8010.9.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080008000705060200050501"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EhStv-0001Gq-DP
	for nfs@lists.sourceforge.net; Wed, 30 Nov 2005 06:25:39 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EhStt-0003oU-2L
	for nfs@lists.sourceforge.net; Wed, 30 Nov 2005 06:25:39 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1133334608.8010.9.camel@lade.trondhjem.org>
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

This is a multi-part message in MIME format.
--------------080008000705060200050501
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hey Trond,

Unfortunately this update patch did not correct the problem for me.
So I decided to dig a little deeper since it appears your not
in favor of reverting the original patch... and sure your were
right in the sense there was "something else at work here"....

It was the simple fact that nfsi->cache_change_attribute was not being 
initialized to jiffies when the nfs inode was being allocated. This
meant when nfs_revalidate_mapping() was called with the
NFS_INO_INVALID_DATA bit was on, nfsi->cache_change_attribute
was not being changed, it was actually being set!

This caused the next called to nfs_verify_change_attribute() to
return true instead false, which meant (indirectly) the dentry
was never released and the otw look was not happening even when
it was noticed the mtime of the directory had changed....

The attached patch does fix the problem for me.

steved.



--------------080008000705060200050501
Content-Type: text/x-patch;
 name="linux-2.6.14-nfs-cache-init.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.14-nfs-cache-init.patch"

Make sure cache_change_attribute is initialized to jiffies
so when the mtime changes on directory, the directory
will be refreshed.

Signed-off by: Steve Dickson <steved@redhat.com>
---------------------------------------------
--- linux-2.6.14/fs/nfs/inode.c.orig	2005-11-29 20:53:57.000000000 -0500
+++ linux-2.6.14/fs/nfs/inode.c	2005-11-30 08:55:14.000000000 -0500
@@ -2066,6 +2066,7 @@ static struct inode *nfs_alloc_inode(str
 		return NULL;
 	nfsi->flags = 0UL;
 	nfsi->cache_validity = 0UL;
+	nfsi->cache_change_attribute = jiffies;
 #ifdef CONFIG_NFS_V3_ACL
 	nfsi->acl_access = ERR_PTR(-EAGAIN);
 	nfsi->acl_default = ERR_PTR(-EAGAIN);

--------------080008000705060200050501--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
