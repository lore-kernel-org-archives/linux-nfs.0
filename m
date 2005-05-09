From: Murray Trainer <mtrainer@central-data.net>
Subject: Accessing other shares from NFS mounted home directories
Date: Mon, 09 May 2005 22:11:06 +0800
Message-ID: <1115647866.21417.51.camel@vserver.central-data.net>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DV8vx-0002B3-Rb
	for nfs@lists.sourceforge.net; Mon, 09 May 2005 07:08:33 -0700
Received: from [202.81.208.11] (helo=mx.central-data.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DV8vw-0007eV-50
	for nfs@lists.sourceforge.net; Mon, 09 May 2005 07:08:33 -0700
Received: from [192.168.245.52] (unknown [192.168.245.52])
	by mx.central-data.net (Postfix) with ESMTP id D337333E97
	for <nfs@lists.sourceforge.net>; Mon,  9 May 2005 21:43:18 +0800 (WST)
To: NFS Mailing List <nfs@lists.sourceforge.net>
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

Hi All,

We mount /home on our front end Linux machines via NFS from a backend
Linux NFS file server.  This is nice and simple and reliable so far.  We
want our user's to be able to access other shares but make them appear
under their home directory, eg mount remote_share under
/home/username/Shares/remote_share.  We could use automount or pam_mount
to do the mounting when the user logs in.  But the problem is 
that, unless there is some trick or new feature I am unaware of, NFS
doesn't appear to be able to mount remote filesystems under these NFS
home directories on the front-end Linux NFS client machine.  

Mounting the remote filesystems elsewhere on the server and using
symbolic links to point to make them appear to be under the user's home
directory appears to be the only solution.  If anyone knows of a better
way to achieve this I would greatly appreciate hearing about it.  If we
go the symbolic links way, automating the process of creating the mounts
and the symbolic links appears to be messy.  It was also suggested to me
that I use the mount with the --bind option but I can't see how this
would allow me to achieve mounts under the home directory.  Automount
may be another option but I not that familiar with it.

Does anyone have any suggestions on how best to implement a solution for
the above situation?

Thanks

Murray



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
