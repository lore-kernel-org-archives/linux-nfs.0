From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: stale file handles if you mix IP and domain in /etc/exports
Date: Thu, 21 Mar 2002 10:00:57 +1100 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15513.5289.928458.843777@notabene.cse.unsw.edu.au>
References: <Pine.LNX.4.44.0203200848130.3761-100000@dunlop.dub.ie.alphyra.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16np3Q-0005N5-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 14:59:37 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <paulj@alphyra.ie>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Thu, 21 Mar 2002 09:59:01 +1100
To: Paul Jakma <paulj@alphyra.ie>
In-Reply-To: message from Paul Jakma on Wednesday March 20
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

On Wednesday March 20, paulj@alphyra.ie wrote:
> hi,
> 
> i have a curious problem with exports...
> 
...
> basically it seems a linux nfs server can not allow clients to 
> access various volumes on IP or domain on a per volume basis. the 
> client must be "authenticated" using one type of match only for 
> all volumes the server exports.
> 
> is this a known problem?

Yes.  It was fixed in 0.3.3 ....
> 
> (happens with latest RH72 updates nfs-utils, and also the nfs-utils 
> currently in rawhide, ie nfs-utils-0.3.3-2)

.. which makes me question this statement.

Have you installed nfs-utils-0.3.3-2 and then unexported everything
and re-exported again (preferrably via a reboot just to be sure).

NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
