From: David Cureton <david.cureton@catapult.com>
Subject: The missing link
Date: Mon, 02 May 2005 17:50:40 +1000
Message-ID: <4275DBD0.1040309@catapult.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DSVhY-0003Px-6v
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 00:50:48 -0700
Received: from [192.94.66.29] (helo=catapult-mx.catapult.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DSVhX-0002s8-NU
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 00:50:48 -0700
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

Hi,
    I am using a SuSE 9.2 system as an NFS server and are seeing some
strange results. The server holds our home directories and exports a
number of disks to all the other workstations in the group.  The setup
is somewhat strange in that the first NFS mount, a directory called
"server", containing all the mountpoint for the subsequent mounting of
the other exported partitions


eg.  /server exported from the fileserver contains

drwxr-xr-x   4 root root 288 2005-04-01 15:32 .
lrwxrwxrwx   1 root root  27 2005-03-24 16:25 ./Shared ->
/server/volumes/vol0/Shared
lrwxrwxrwx   1 root root  26 2005-03-24 10:55 ./Staff ->
/server/volumes/vol0/Staff
lrwxrwxrwx   1 root root  27 2005-03-24 10:52 ./users ->
/server/volumes/vol0/users/
lrwxrwxrwx   1 root root  26 2005-03-24 10:51 ./usr1 ->
/server/volumes/vol0/usr1/
lrwxrwxrwx   1 root root  26 2005-03-24 10:51 ./usr2 ->
/server/volumes/vol0/usr2/
lrwxrwxrwx   1 root root  25 2005-03-24 10:53 ./usr3 ->
/server/volumes/vol0/usr3
lrwxrwxrwx   1 root root  25 2005-03-24 10:54 ./usr4 ->
/server/volumes/vol0/usr4
lrwxrwxrwx   1 root root  25 2005-03-24 10:54 ./usr5 ->
/server/volumes/vol0/usr5
drwxr-xr-x   5 root root 120 2005-03-29 13:52 ./volumes
drwxr-xr-x  12 root root 272 2005-04-01 16:00 ./volumes/vol0
drwxr-xr-x   4 root root  80 2005-03-23 17:53 ./volumes/vol1
drwxr-xr-x   2 root root  48 2005-03-29 13:52 ./volumes/vol2


The fstab of a client therefore looks like:

melbourne-fs3:/server      /server    nfs     defaults  0 2
melbourne-fs3:/server/volumes/vol2      /server/volumes/vol2     nfs
defaults  0 2
melbourne-fs3:/server/volumes/vol1      /server/volumes/vol1     nfs
defaults  0 2
melbourne-fs3:/server/volumes/vol0      /server/volumes/vol0     nfs
defaults  0 2


The clients  then have  a link from /Staff  --> /server/Staff which in
it self is a link to /server/volumes/vol0/Staff
i.e. /Staff (link on client's root)  --> /server/Staff (link on nfs
mount) --> /server/volumes/vol0/Staff (Real NFS exported directory)

This works fine most of the time and allows us to  move data between
disks without having to change links of the clients. It also allows us
to add new disks an easily bring them into use.

However on occasion we have noticed that the /server/Staff link just
disappears for some SuSE9.2 clients and the user no longer has access to
there home directory. All other clients still have the link available
and they are fine.

It appears that the client looses the /server/Staff  symbolic link out
of its NFS cache and forgets about it until the cache expires and does a
readdirplus on the /server directory.   All other accesses to the
/server director on the NFS client prior to the cache update  only check
the attibutes of the /server directory and it contents (excluding the
/server/Staff link) and as nothing has changed, uses the cached data.

I am at a loss as to how I can debug this NFS problem  further.  I have
done copious amounts of searching on google and have not found a similar
issue.

Server and client particulars are:

Both SuSE 9.2
Server 'uname -a': Linux melbourne-fs3 2.6.8-24.14-default #1 Tue Mar 29
09:27:43 UTC 2005 i686 athlon i386 GNU/Linux
Kernel based NFS server

Client 'uname -a': Linux cockatoo 2.6.8-24-default #1 Wed Oct 6 09:16:23
UTC 2004 i686 athlon i386 GNU/Linux



Any assistance as to how I should go about debuging such a beast would
be greatly appreciated, especially as it only happens 1 a fortnight
further componding being able to resolve it

David










-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
