From: Brian Tinsley <btinsley@emageon.com>
Subject: Re: NFS as a Cluster File System.
Date: Thu, 09 Jan 2003 17:09:02 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E1E010E.4020902@emageon.com>
References: <F112Sbh29cM3oryKFRJ0001248d@hotmail.com> <20030109215019.GN2437@marowsky-bree.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Lorn Kay <lorn_kay@hotmail.com>,  nfs@lists.sourceforge.net,
 linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tisch.mail.mindspring.net ([207.69.200.157])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Wlma-0005bR-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Jan 2003 15:08:16 -0800
To: Lars Marowsky-Bree <lmb@suse.de>
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

Lars Marowsky-Bree wrote:

>On 2003-01-09T19:39:50,
>   Lorn Kay <lorn_kay@hotmail.com> said:
>
>>Is NFS a viable CFS? (I'm cross posting this due to a discussion on the the linux-ha list recently.)
>>    
>>
>NFS might be a viable system for making content available in a cluster, given a highly available NFS sever (not that easy to do right, actually) and provided that the bandwidth and latency is good enough for you; file locking might also be a problem.
>
There are numerous threads in the NFS mailing list archives (and 
probably in the NFS HOWTO - it's been quite a while since I've read it) 
on how to set up a HA NFS cluster. Yes, there are quite a few pitfalls 
to watch for and some applications may not behave well in this 
configuration, but it's definitely achievable.

>However, it is NOT a "CFS", which people commonly use to refer to a filesystem which is distributed and usually shares the same storage system connected to all nodes.
>
Yes, good clarification.




-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
