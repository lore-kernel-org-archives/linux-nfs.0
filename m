From: "John Medway, Enuclia Semiconductor" <john.medway@enuclia.com>
Subject: Autofs-mounted NFS directories disappearing
Date: Mon, 10 Oct 2005 14:10:43 -0700
Message-ID: <6.2.1.2.2.20051010141020.05b86a00@mail.enuclia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EP4vV-0002CJ-D4
	for nfs@lists.sourceforge.net; Mon, 10 Oct 2005 14:11:17 -0700
Received: from spatula.dreamhost.com ([66.33.205.9] ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EP4ve-0000rD-UE
	for nfs@lists.sourceforge.net; Mon, 10 Oct 2005 14:11:27 -0700
Received: from HEADACHE.ERROR (66.236.17.134.ptr.us.xo.net [66.236.17.134])
	by spatula.dreamhost.com (Postfix) with ESMTP id 9442517D015
	for <nfs@lists.sourceforge.net>; Mon, 10 Oct 2005 14:11:15 -0700 (PDT)
To: nfs@lists.sourceforge.net
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

Intermittently, sub directories of people's home dirs go bad on some of my 
clients and report stale NFS handles when the user tries to access the 
directory. Sometimes when this occurs, the subdir has been accessed in the 
last few minutes. Sometimes, not for days (and it's just still mounted 
because they have a shell sitting in it).

It's usually a couple of levels down, say ~foo/a/b/c and "c" will go stale. 
If you're in it with a shell you get Stale NFS handle. If you're in "b" and 
do an ls, "c" doesn't appear. If the missing/stale dir "c" is listed on 
another machine, or on the server, it usually immediately goes un-stale on 
the problem box.

Thoughts?

Client:
         Redhat 2.4.21-32.0.1.EL #1
                 Tue May 17 17:55:54 EDT 2005 i686 athlon i386 GNU/Linux
         nfs-utils-1.0.6-33EL
         redhat-config-nfs-1.0.13-6
         autofs-4.1.3-130

         /etc/auto.home entry: (pardon the wrap on this one)
                 test  -vers=3,rw,suid,hard,intr,rsize=1024,wsize=1024
                 boston:/p02/users/test


Server:
         Redhat 2.6.9-5.ELsmp #1 SMP
                 Wed Jan 5 19:30:39 EST 2005 i686 athlon i386 GNU/Linux
         system-config-nfs-1.2.8-1
         nfs-utils-1.0.6-46
         autofs-4.1.3-131

         /etc/exports:
                 /p02   *(rw,sync,no_wdelay,root_squash,no_subtree_check)


RPC info:
         This is identical both as "-p server" on the client, and as
         "-p localhost" on server:

         100000    2   tcp    111  portmapper
         100000    2   udp    111  portmapper
         100003    2   tcp   2049  nfs
         100003    2   udp   2049  nfs
         100003    3   tcp   2049  nfs
         100003    3   udp   2049  nfs
         100003    4   tcp   2049  nfs
         100003    4   udp   2049  nfs
         100005    1   tcp    986  mountd
         100005    1   udp    983  mountd
         100005    3   tcp    986  mountd
         100005    3   udp    983  mountd
         100011    1   tcp    938  rquotad
         100011    1   udp    935  rquotad
         100011    2   tcp    938  rquotad
         100011    2   udp    935  rquotad
         100021    1   tcp  32769  nlockmgr
         100021    1   udp  32770  nlockmgr
         100021    3   tcp  32769  nlockmgr
         100021    3   udp  32770  nlockmgr
         100021    4   tcp  32769  nlockmgr
         100021    4   udp  32770  nlockmgr
         100024    1   tcp  32768  status
         100024    1   udp  32768  status




-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
