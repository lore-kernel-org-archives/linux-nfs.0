From: "Lorn Kay" <lorn_kay@hotmail.com>
Subject: Re: NFS as a Cluster File System.
Date: Thu, 09 Jan 2003 23:13:22 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F43H06Ym8Es5FEnoLH80000317f@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from f43.law11.hotmail.com ([64.4.17.43] helo=hotmail.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18WltQ-0007ji-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Jan 2003 15:15:20 -0800
To: lmb@suse.de, nfs@lists.sourceforge.net, linux-ha@muc.de
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


>However, it is NOT a "CFS", which people commonly use to refer to a 
>filesystem
>which is distributed and usually shares the same storage system connected 
>to
>all nodes.
>
>I believe there might be a confusion of words here ;-)
>
>
>Sincerely,
>     Lars Marowsky-Brée <lmb@suse.de>

Sorry, still confused about what a "CFS" really is. In "In Search Of 
Clusters" Gregory Pfister takes the position that a distributed file system 
is what he calls a valid "single system image" file system, what I would 
take to mean a cluster file system (though he doesn't use those words).

I guess you are saying a clustered file system isn't necessarily supporting 
a cluster of application servers but is itself stored on a cluster. (A 
single server can be the only server using a cluster file system.) ?

--K



_________________________________________________________________
Help STOP SPAM: Try the new MSN 8 and get 2 months FREE* 
http://join.msn.com/?page=features/junkmail



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
