From: Chuck Lever <chuck.lever@oracle.com>
Subject: Desynchronized ncommit
Date: Thu, 19 Apr 2007 14:23:22 -0400
Message-ID: <4627B39A.9070604@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040707080500000604000909"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HebJq-00014y-Po
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 11:25:23 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HebJt-00072J-4C
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 11:25:25 -0700
Received: from rgmgw3.us.oracle.com (rgmgw3.us.oracle.com [138.1.186.112])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id
	l3JIPHM4002827
	for <nfs@lists.sourceforge.net>; Thu, 19 Apr 2007 12:25:17 -0600
Received: from acsmt350.oracle.com (acsmt350.oracle.com [141.146.40.150])
	by rgmgw3.us.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l3JDpY24006182
	for <nfs@lists.sourceforge.net>; Thu, 19 Apr 2007 12:25:01 -0600
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

This is a multi-part message in MIME format.
--------------040707080500000604000909
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I've noticed this message in my system log over the past few days:

Apr 17 10:14:04 schiele kernel: NFS: desynchronized value of nfs_i.ncommit.

It looks like it started appearing when the following patch was applied 
to 2.6.21-rc.  Any suggestions on what I can do to debug this further?

     NFS: Fix a list corruption problem

     We must remove the request from whatever list it is currently on 
before we
     can add it to the dirty list.

     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e5d7cac..ad2e91b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -280,8 +280,10 @@ static int nfs_page_mark_flush(struct page *page)
                 spin_lock(req_lock);
         }
         spin_unlock(req_lock);
-       if (nfs_set_page_writeback(page) == 0)
+       if (nfs_set_page_writeback(page) == 0) {
+               nfs_list_remove_request(req);
                 nfs_mark_request_dirty(req);
+       }
         ret = test_bit(PG_NEED_FLUSH, &req->wb_flags);
         nfs_unlock_request(req);
         return ret;

--------------040707080500000604000909
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------040707080500000604000909
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------040707080500000604000909
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040707080500000604000909--
