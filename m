From: Daniel Barbar <dbarbar@legato.com>
Subject: Maximum number of nfsd daemons?
Date: Wed, 31 Jul 2002 20:45:20 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <FB5B6B9A4BA0104886C8394BB2B7C7B803ACAD5A@TOMBO.legato.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp1.legato.com ([137.69.200.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17a6v6-0002PR-00
	for <nfs@lists.sourceforge.net>; Wed, 31 Jul 2002 20:46:36 -0700
Received: from mta1.legato.com (mta1 [137.69.1.14])
	by smtp1.legato.com (Switch-2.1.3/Switch-2.1.0) with ESMTP id g713kZC29468
	for <nfs@lists.sourceforge.net>; Wed, 31 Jul 2002 20:46:35 -0700 (PDT)
Received: from pa-mail.legato.com (tombo.legato.com [137.69.23.45])
	by mta1.legato.com (Switch-2.1.3/Switch-2.1.0) with ESMTP id g713kYF12794
	for <nfs@lists.sourceforge.net>; Wed, 31 Jul 2002 20:46:34 -0700 (PDT)
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

Hi,

  We recently moved one of our NFS servers from a Sun machine running
Solaris 7 to an Intel box running SuSE Linux 8.0 (kernel 2.4.18). We are
experiencing some (rather heavy) performance problems, more so for clients
accesing the service over our WAN link.
  I'm starting to go through the excerise of tuning the NFS system, and
started first by trying to increase the number of nfsd process. It seems
that there is a hard coded limit of 128 processes, is that correct? If true,
is it because one shouldn't expect any substantial performance increase by
setting the number of nfsd threads to a number larger than 128?
  Thanks in advance for your help. Regards,

---
Daniel Barbar


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
