From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: sendmail "cannot fsync directory" after 2.4 -> 2.6
Date: Thu, 09 Sep 2004 08:15:07 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <413FF4EB.2070607@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5ID8-0004xa-J2
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 23:15:10 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C5ID7-0007Zx-Vs
	for nfs@lists.sourceforge.net; Wed, 08 Sep 2004 23:15:10 -0700
Received: from internaldeliver.acheron.informatik.uni-muenchen.de (localhost [127.0.0.1])
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id 707C2435B5
	for <nfs@lists.sourceforge.net>; Thu,  9 Sep 2004 08:15:08 +0200 (CEST)
Received: from [141.84.1.141] (galois.bio.ifi.lmu.de [141.84.1.141])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id 6922243575
	for <nfs@lists.sourceforge.net>; Thu,  9 Sep 2004 08:15:08 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

Hi,

we've been running SuSE 9.0 with kernel 2.4.21 for some months. Two weeks
ago we switched to 2.6.8.1 from kernel.org.

Our diskless clients get (due to lack of a local hd) everything via nfs,
including /var/spool/mqueue. The /var directories for the clients (one
seperate for each client) are exported with "sync" and mounted with
"tcp,hard,intr,lock,sync", and this has not changed when switching from
2.4 to 2.6. But after we switched to 2.6.8.1, we get messages

Sep  9 08:03:13 galois sendmail[21596]: sync_dir: cannot fsync directory .: Invalid argument
Sep  9 08:04:02 galois sendmail[21649]: i89641NZ021648: SYSERR(root): sync_dir: cannot fsync directory .: Invalid argument

every time we send a mail with "mail -s test root" or similar. Note that
sendmail is running as daemon on every client, but only listening on
localhost. The sendmail package has REQUIRES_DIR_FSYNC enabled.

I tried mounting the nfs dir with "dirsync" additionally, but it doesn't
help. Also, it doesn't make a difference if the exported fs on the server
is ext3 or reiserfs. Since it works on local disks and worked also over
NFS with kernel 2.4.21, I guess it is a bug in 2.6? Or should it not work
with nfs and 2.4 just didn't notice?

cu,
Frank


-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
