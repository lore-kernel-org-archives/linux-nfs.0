From: Michael Haverkamp <mhaverkamp@kcp.com>
Subject: Re: permission denied under load
Date: Thu, 11 Nov 2004 11:25:38 -0600
Message-ID: <4193A092.6030900@kcp.com>
References: <41937BBE.5010208@kcp.com> <20041111145815.GM13905@fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CSIhh-0003qk-OG
	for nfs@lists.sourceforge.net; Thu, 11 Nov 2004 09:25:49 -0800
Received: from mailhost2.os.kcp.com ([198.124.201.32])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CSIhh-00026o-4n
	for nfs@lists.sourceforge.net; Thu, 11 Nov 2004 09:25:49 -0800
To: Jan Kasprzak <kas@fi.muni.cz>
In-Reply-To: <20041111145815.GM13905@fi.muni.cz>
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

There is nothing in the logs about privileged ports or unprivileged ports.

Also, in case I wasn't clear in my first email, the problem happens to 
clients that already have the filesystem mounted.  Does that mean that 
mountd is no longer involved?

Example:

$ mount | grep fmt
/usr/fmt on nfs:/usr/fmt remote/read 
only/setuid/bg/timeo=200/proto=udp/xattr/dev=46400fd on Thu Nov 11 
05:13:15 2004
$ ls -ld /usr/fmt/coreutils
ls: /usr/fmt/coreutils: Permission denied
$

Wait a while

$ ls -ld /usr/fmt/coreutils
drwxr-xr-x    6 root     root          144 May  7  2003 /usr/fmt/coreutils


Jan Kasprzak wrote:
> Michael Haverkamp wrote:
> : I have a system running Gentoo Linux with a 2.6.9 kernel that is acting 
> : as an NFS server for several Solaris 7,8,9 systems.  Everything appears 
> : to work fine for a while, but at seemingly random times the clients get 
> : "Permission denied" when trying to access a file or directory that they 
> : are normally able to access.  This problem may persist for a few 
> : minutes, but then everything returns to normal again.  This happens 
> : multiple times a day.
> : 
> 	See the list archive from the last week or so - I think this
> is an "out of privileged ports" problem. Does by any chance the server
> (rpc.mountd in particular) complain about unprivileged ports?
> 
> -Yenya
> 

-- 
Michael Haverkamp


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
