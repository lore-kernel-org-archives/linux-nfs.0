From: fumihiko kakuma <kakmy@mvh.biglobe.ne.jp>
Subject: exporfs no keep sequence of etab entry
Date: Wed, 09 Jul 2003 20:20:32 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030709202020.5172.KAKMY@mvh.biglobe.ne.jp>
Reply-To: kakuma@tko.ncs.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rcpt-expgw.biglobe.ne.jp ([202.225.89.169])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19aD0E-0004T4-00
	for <nfs@lists.sourceforge.net>; Wed, 09 Jul 2003 04:20:51 -0700
Received: from smtp-gw.biglobe.ne.jp
	by rcpt-expgw.biglobe.ne.jp (nkrw/5508310702) with ESMTP id h69BKgV18942
	for <nfs@lists.sourceforge.net>; Wed, 9 Jul 2003 20:20:42 +0900 (JST)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

When we added a entry by exportfs command or changed it,
the sequence of entry of etab file becomes, except added or
changed entry, reverse the last time.

Therefore the priority of entry applied nfs client isn't kept.
This occures on all entry type.

System: GNU-Debian/Linux 
Architecture: i386
Package: nfs-kernel-server 1.0-2 


*example.

~# exportfs -v
/share1         <world>(rw,async,wdelay,root_squash)
~# exportfs -o rw *.test1.co.jp:/share
~# exportfs -o rw *.test2.co.jp:/share
~# exportfs -v
/share          *.test2.co.jp(rw,async,wdelay,root_squash)
/share          *.test1.co.jp(rw,async,wdelay,root_squash)
/share1         <world>(rw,async,wdelay,root_squash)
~# exportfs -o rw *.test3.co.jp:/share
~# exportfs -v
/share          *.test3.co.jp(rw,async,wdelay,root_squash)
/share          *.test1.co.jp(rw,async,wdelay,root_squash)
/share          *.test2.co.jp(rw,async,wdelay,root_squash)
/share1         <world>(rw,async,wdelay,root_squash)
~# exportfs -o rw *.test4.co.jp:/share
~# exportfs -v
/share          *.test4.co.jp(rw,async,wdelay,root_squash)
/share          *.test2.co.jp(rw,async,wdelay,root_squash)
/share          *.test1.co.jp(rw,async,wdelay,root_squash)
/share          *.test3.co.jp(rw,async,wdelay,root_squash)
/share1         <world>(rw,async,wdelay,root_squash)
~# exportfs -o rw *.test4.co.jp:/share
~# exportfs -v
/share          *.test4.co.jp(rw,async,wdelay,root_squash)
/share          *.test3.co.jp(rw,async,wdelay,root_squash)
/share          *.test1.co.jp(rw,async,wdelay,root_squash)
/share          *.test2.co.jp(rw,async,wdelay,root_squash)
/share1         <world>(rw,async,wdelay,root_squash)
~# cat /var/lib/nfs/etab
/share  *.test2.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share  *.test1.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share  *.test3.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share  *.test4.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share1 *(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
~# exportfs -o rw *.test11.co.jp:/share1
~# exportfs -o rw *.test12.co.jp:/share1
~# exportfs -o rw *.test13.co.jp:/share1
~# exportfs -v
/share1         *.test13.co.jp(rw,async,wdelay,root_squash)
/share1         *.test11.co.jp(rw,async,wdelay,root_squash)
/share1         *.test12.co.jp(rw,async,wdelay,root_squash)
/share          *.test2.co.jp(rw,async,wdelay,root_squash)
/share          *.test1.co.jp(rw,async,wdelay,root_squash)
/share          *.test3.co.jp(rw,async,wdelay,root_squash)
/share          *.test4.co.jp(rw,async,wdelay,root_squash)
/share1         <world>(rw,async,wdelay,root_squash)
~# cat /var/lib/nfs/etab
/share1 *.test12.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share1 *.test11.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share1 *.test13.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share  *.test4.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share  *.test3.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share  *.test1.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share  *.test2.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share1 *(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
~# exportfs -o rw @hosts1:/share
~# exportfs -o rw @hosts2:/share
~# exportfs -o rw @hosts3:/share
~# exportfs -v
/share1         *.test12.co.jp(rw,async,wdelay,root_squash)
/share1         *.test11.co.jp(rw,async,wdelay,root_squash)
/share1         *.test13.co.jp(rw,async,wdelay,root_squash)
/share          *.test4.co.jp(rw,async,wdelay,root_squash)
/share          *.test3.co.jp(rw,async,wdelay,root_squash)
/share          *.test1.co.jp(rw,async,wdelay,root_squash)
/share          *.test2.co.jp(rw,async,wdelay,root_squash)
/share          @hosts3(rw,async,wdelay,root_squash)
/share          @hosts1(rw,async,wdelay,root_squash)
/share          @hosts2(rw,async,wdelay,root_squash)
/share1         <world>(rw,async,wdelay,root_squash)
~# cat /var/lib/nfs/etab
/share1 *.test13.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share1 *.test11.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share1 *.test12.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share  *.test2.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share  *.test1.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share  *.test3.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share  *.test4.co.jp(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share  @hosts2(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share  @hosts1(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share  @hosts3(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)
/share1 *(rw,async,wdelay,hide,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)


This is because of queing the information of entry to variable exportlist
at reverse of sequence of reading etab file.

I think that the following code will go well.
However the result of 'exportfs -v' will be displayed in reverse until now.
It means that is high priority with more under entry.


=================================================================================
--- support/export/export.c.orig	Wed Jul  9 17:36:58 2003
+++ support/export/export.c	Wed Jul  9 17:36:59 2003
@@ -124,15 +124,34 @@
 	nfs_export	**epp;
 	int		type = exp->m_client->m_type;
 	int		slen = strlen(exp->m_export.e_path);
+	int		eslen;
 
 	if (type < 0 || type >= MCL_MAXTYPES)
 		xlog(L_FATAL, "unknown client type in export_add");
 
 	epp = exportlist + type;
-	while (*epp && slen < strlen((*epp)->m_export.e_path))
+	while (*epp && slen <= (eslen = strlen((*epp)->m_export.e_path))) {
+		if (slen == eslen && 
+		(*epp)->m_mayexport && (*epp)->m_changed)
+			break;
 		epp = &((*epp)->m_next);
-	exp->m_next = *epp;
-	*epp = exp;
+	}
+	if (!(*epp)) {						/* queing ahead */
+		exp->m_next = *epp;
+		*epp = exp;
+	} else if (slen > eslen) {				/* queing ahead */
+		exp->m_next = *epp;
+		*epp = exp;
+	} else if (slen < eslen) {				/* queing behind */
+		exp->m_next = (*epp)->m_next;
+		(*epp)->m_next = exp;
+	} else if ((*epp)->m_mayexport && (*epp)->m_changed){	/* queing ahead */
+		exp->m_next = *epp;
+		*epp = exp;
+	} else {						/* queing behind */
+		exp->m_next = (*epp)->m_next;
+		(*epp)->m_next = exp;
+	}
 }
 
 nfs_export *
=================================================================================

-- 
fumihiko kakuma <kakmy@mvh.biglobe.ne.jp>



-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
