From: Alexander Bergolth <leo@strike.wu-wien.ac.at>
Subject: Allowed characters in nfsv4 filenames
Date: Sat, 10 Jul 2004 12:37:24 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40EFC6E4.7000203@strike.wu-wien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BjFEc-0000sJ-ND
	for nfs@lists.sourceforge.net; Sat, 10 Jul 2004 03:37:34 -0700
Received: from strike.wu-wien.ac.at ([137.208.8.200])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BjFEc-0002cj-9T
	for nfs@lists.sourceforge.net; Sat, 10 Jul 2004 03:37:34 -0700
Received: from localhost (localhost.localdomain [127.0.0.1])
	by strike.wu-wien.ac.at (Postfix) with ESMTP id 960152000ED
	for <nfs@lists.sourceforge.net>; Sat, 10 Jul 2004 12:37:27 +0200 (CEST)
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

Hi!

When I'm trying to access files on a NFSv4 mounted server containing=20
Latin-1 characters, those files are displayed in the directory listing=20
but cannot be opened or stat'ed.
Does NFSv4 only accept filenames in UTF-8?

[root@barney nfstest]# ls --show-control-chars
server-created-=E4=F6=FC
[root@barney nfstest]# ls -b
server-created-\344\366\374
[root@barney nfstest]# ls -l --show-control-chars
total 0
?---------  ? ? ? ?           ? server-created-=E4=F6=FC
[root@barney nfstest]# ls --show-control-chars server-created-=E4=F6=FC
ls: server-created-=E4=F6=FC: Invalid argument
[root@barney nfstest]# stat server-created-=E4=F6=FC
stat: cannot stat `server-created-\344\366\374': Invalid argument


Moreover I cannot create files on the client containing Latin-1 character=
s:

[root@barney nfstest]# touch client-=E4=F6=FC
touch: setting times of `client-\344\366\374': Invalid argument
[root@barney nfstest]# ls -l client*
ls: client*: No such file or directory


Is this the expected behavior?
Is there any way to use ISO-8859-1 filenames with NFSv4?

Thanks in advance,
--leo

P.S.: I am using kernel 2.6.6-1.435 from Fedora Core 2.

--=20
-------------------------------------------------------
Alexander (Leo) Bergolth          leo@leo.wu-wien.ac.at
WU-Wien - Zentrum fuer Informatikdienste - Projektbuero


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
