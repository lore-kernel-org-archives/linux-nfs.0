From: Rock Gordon <rockgordon@yahoo.com>
Subject: searching ".." in find_fh_dentry
Date: Mon, 24 Jun 2002 15:39:12 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020624223912.20483.qmail@web14807.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web14807.mail.yahoo.com ([216.136.224.223])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17McUK-00068r-00
	for <nfs@lists.sourceforge.net>; Mon, 24 Jun 2002 15:39:12 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi all,

Does anybody have a list of filesystems that are
capable of searching parent entries? (like "..") This
I ask because I want to find out what filesystems are
currently supported by Linux' NFS implementation ..
(take 2.4.18, say).

Looking at find_fh_dentry() in nfsd/nfsfh.c, it seems
to me that filesystems that don't support searching
for "..", might not work with NFS ...

Thanks and regards,
Rock

__________________________________________________
Do You Yahoo!?
Yahoo! - Official partner of 2002 FIFA World Cup
http://fifaworldcup.yahoo.com


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
