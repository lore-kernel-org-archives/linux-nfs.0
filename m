From: Matthew Boeckman <matthewb@saepio.com>
Subject: cache information
Date: Tue, 26 Mar 2002 11:54:58 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CA0B5F2.2040509@saepio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Received: from [208.10.117.3] (helo=velocity.saepio.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16pvAt-00072o-00
	for <nfs@lists.sourceforge.net>; Tue, 26 Mar 2002 09:55:59 -0800
Received: from saepio.com (leto-ii [10.1.1.100])
	by velocity.saepio.com (8.11.2/8.9.3) with ESMTP id g2QJ0O102800
	for <nfs@lists.sourceforge.net>; Tue, 26 Mar 2002 13:00:24 -0600
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

I'm trying to find out information on my client side cacheing. Right now 
I have 3 linux boxen that are using a 10hour cache of the mounted 
filesystem, and I want to track (for example) how many of the getattr 
calls are answered from the cache, and how many actually contact the 
server. Also interested in where the cache exists (RAM, swap, etc) and 
what, if any, impact that is having on the system, like how large the 
cache is, etc.

Thanks!
-- 
Matthew Boeckman			(816) 777-2160
Manager - Systems Integration		Saepio Technologies
== 
						==
/earth is 98% full ... please delete anyone you can.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
