From: Jose Santiago <jsantiago@chrysalisdev.com>
Subject: RE: NFS Problem
Date: Thu, 12 Dec 2002 17:57:02 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DF9224E.8050009@chrysalisdev.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 89.levincom.com ([198.78.56.89] helo=chrysalis-sbs1.chrysalisdev.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18MdCa-0000Pd-00
	for <nfs@lists.sourceforge.net>; Thu, 12 Dec 2002 15:57:12 -0800
To: Muhammad Sibtain Bashir <sibtain@pseb.org.pk>,
	nfs@lists.sourceforge.net
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

What are the permissions on the directories that you are trying to write 
to via NFS? What user is trying to do the write? Be aware, that root 
maps to user nobody via NFS unless you root_squash.

 > now when i mount the directories on my client machine it get mounted
 > okay and i can read any file in the mounted directories but as above i
 > have given the write permision as well ,but i cant write any thing and
 > this message show   * permission denied*.



-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
