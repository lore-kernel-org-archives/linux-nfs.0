From: "Tradebit Service" <info@tradebit.com>
Subject: blocked remote subdirectories
Date: Thu, 8 Dec 2005 03:29:28 +0100
Message-ID: <E1EkBVL-0003Ee-9s@mail.sourceforge.net>
Reply-To: <info@tradebit.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EkBVN-0002j0-O9
	for nfs@lists.sourceforge.net; Wed, 07 Dec 2005 18:27:33 -0800
Received: from aibo.runbox.com ([193.71.199.94] helo=cujo.runbox.com)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1EkBVL-0003Ee-9s
	for nfs@lists.sourceforge.net; Wed, 07 Dec 2005 18:27:33 -0800
Received: from [10.9.9.9] (helo=fetch.runbox.com)
	by greyhound.runbox.com with esmtp (Exim 4.34)
	id 1EkBVI-0004lo-VI
	for nfs@lists.sourceforge.net; Thu, 08 Dec 2005 03:27:28 +0100
Received: from [84.168.156.66] (helo=muelleimer)
	by fetch.runbox.com with asmtp  (uid:433466 )  (Exim 4.34)
	id 1EkBVI-00072M-Ms
	for nfs@lists.sourceforge.net; Thu, 08 Dec 2005 03:27:28 +0100
To: <nfs@lists.sourceforge.net>
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

hi everybody,

for a few days now i run a new setup
with NFS on RHEL4 (kmountd nfs-utils 1.0.6) and
from our storage I serve a few hundred thousand
files of all sizes to 3 other servers.

now, in these (around 14) days, I had 5 incidents of
blocked subdirectories on the server from different clients.

2 times the directory "came back" after a few minutes 
(have seen that mail too late) and in the 3 other cases,
it did not (maybe I was too fast).

for the time the dir is blocked, the failure looks
like a rights mismanagement, but nothing changed it just
denies access for minutes/hours.

the directories were deep in the dir tree, but random as
it seems.

does anyone know, how to prevent that in the future?
what could be the cause of these voodoo incidents?

any help appreciated,

thx,
Ralf Schwoebel
http://www.tradebit.com/



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
