From: Chris Jensen <chris-nfs@drspirograph.com>
Subject: Stale file handle
Date: Mon, 3 Feb 2003 19:03:53 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200302031903.53937.chris-nfs@drspirograph.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mta08bw.bigpond.com ([144.135.24.137])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18fbUP-0006u8-00
	for <nfs@lists.sourceforge.net>; Sun, 02 Feb 2003 23:58:01 -0800
Received: from chris ([144.135.24.75]) by mta08bw.bigpond.com
          (Netscape Messaging Server 4.15 mta08bw Jul 16 2002 22:47:55)
          with SMTP id H9Q3GH00.DR6 for <nfs@lists.sourceforge.net>; Mon,
          3 Feb 2003 17:57:53 +1000
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,
I'm getting a stale file handle with a linux file server.
I've been running the file server for a long time now along with another box 
as the client and there has never been any problem (in fact they've both been 
server and client), both the boxes run linux from scratch (entire linux OS 
compiled from source) with kernel 2.4.20 (though they've both gone through 
most of the 2.4.x series).
They've run fine together for over a year, but recently I have tried 
interoperating them with other boxes and I'm getting a real headache from 
Stale File Handles. I've tried RedHat 7.3 and OpenBSD 3.2, all I have to do 
is mount a remote share, and try to untar a file from the share, before the 
end of the file I get a stale file handle error. I should note that both the 
RedHat and OpenBSD systems were running on VMWare, but they had no other 
network connectivity problems either to the boxes sharing nfs, or anything 
else.
I've tried upgrading the servers to the latest nfs-utils (1.0.1). There were 
inconsistancies with DNS resolution (the server wasn't in DNS, so I was 
connecting by IP), but I fixed that. Neither of these things have fixed the 
problem. I've looked in the log files and can find nothing significant.
What's going on here? I'm tearing my hair out!

-- 
Chris Jensen

Public Key: http://drspirograph.com/public_key/

Wait: Did you know that there's a direct correlation between the decline of
Spirograph and the rise in gang activity?  Think about it.
- Dr Spirograph (The Simpsons)



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
