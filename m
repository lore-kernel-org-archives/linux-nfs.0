From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: RE: huge number of intr/s on large nfs server
Date: Tue, 15 Oct 2002 19:02:42 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0210151851450.19850-100000@kenzo.iwr.uni-heidelberg.de>
References: <CFEAJJEGMGECBCJFLGDBMEIACFAA.enorwood@effrem.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, Daniel Phillips <phillips@arcor.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181V67-0006R7-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 10:03:12 -0700
To: Eff Norwood <enorwood@effrem.com>
In-Reply-To: <CFEAJJEGMGECBCJFLGDBMEIACFAA.enorwood@effrem.com>
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

On Tue, 15 Oct 2002, Eff Norwood wrote:

> No, the 3ware card has its own interrupt as do each of the gigabit
> interfaces. Each card (3ware, gigabit) is also on its own bus. The
> SuperMicro MB I'm using has x4 PCI-X busses and one card is in each.

OK, the setup is completely different that the one I imagined.

> I tried this and it was *much* worse. NFS over TCP seems pretty broken right
> now in terms of throughput. Certainly much worse than UDP.

Well, somebody else from this list could help you find out why... just 
make sure that you use the latest patches that were announced here.
However, you should make sure first that the network is in good condition. 
I've already posted several messages on this topic, so please search some 
archives of this list.

> This might get us better numbers, but I'm looking to fix the performance
> over the network - not on local disk. Yes, my test was to have 30 individual
> clients dd 10MB files over NFS to the server.

I'm sorry but I think that we don't understand each other here. You said 
that you tested one dd on the server (so direct access to disk) versus 30 
dd's on clients (so over network). What I meant was to try to test 30 dd's 
on the server (so again direct access to disk) - this is an intermediate 
situation between the 2 that you mentioned and should show how much you 
could get from your disks and what is the involvment of the network.
If this scattered write shows something close to 35 MB/s, then it's the 
disk that limits the writes from the clients and even with a dedicated 
network card for each client you won't get better write peformance over 
NFS. However, if the scattered write shows something significantly better 
than 35 MB/s, then either the network or the congestion mechanism of NFS 
are not working right (or even they both work right and this is the 
maximum that you could get from your setup !).

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
