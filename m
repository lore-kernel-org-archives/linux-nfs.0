From: Brian Tinsley <btinsley@emageon.com>
Subject: Re: NFS as a Cluster File System.
Date: Thu, 09 Jan 2003 15:11:12 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E1DE570.7070207@emageon.com>
References: <F112Sbh29cM3oryKFRJ0001248d@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [63.162.183.250] (helo=emgw2ksrv001.emgdom001.emageon.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18WvGU-0004li-00
	for <nfs@lists.sourceforge.net>; Fri, 10 Jan 2003 01:15:47 -0800
To: Lorn Kay <lorn_kay@hotmail.com>
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

Lorn Kay wrote:

>
> Is NFS a viable CFS? (I'm cross posting this due to a discussion on 
> the the linux-ha list recently.) 

Since there is not a really good cluster filesystem for Linux that is 
not either "half baked" (IMHO - I'm probably going to get smacked over 
that statement!) or cost an arm and a leg, this is exactly the route we 
have taken.

>     The NFS server is a high-quality dedicated machine (Net App, EMC, 
> etc.) 

We've had great success with just using SMP Linux servers. We do have 
one EMC IP4700 in production, and it's a nice system, but I prefer the 
Linux based alternative.

>     Linux clients can use TCP instead of UDP. 

Although I haven't had problems with this in our lab, I believe the NFS 
authors still consider this experimental.


-- 

-[========================]-
-[      Brian Tinsley     ]-
-[ Chief Systems Engineer ]-
-[        Emageon         ]-
-[========================]-






-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
