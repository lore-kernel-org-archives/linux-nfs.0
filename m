From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: PATCH - RPC/TCP 2 of 4 - Allow  SO_REUSEADDR for NFS sockets
Date: Tue, 13 Aug 2002 16:01:42 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15704.41158.32143.348415@notabene.cse.unsw.edu.au>
References: <15704.30117.665447.109832@notabene.cse.unsw.edu.au>
	<Pine.BSO.4.33.0208122322420.6948-100000@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eUmA-00033A-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 23:03:30 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.85] == wireless-085.wireless.cse.unsw.EDU.AU)
	(for <cel@citi.umich.edu>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Tue, 13 Aug 2002 16:02:11 +1000
To: Chuck Lever <cel@citi.umich.edu>
In-Reply-To: message from Chuck Lever on Monday August 12
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


[ cc list trimmed ]
On Monday August 12, cel@citi.umich.edu wrote:
> it's been suggested that the client should also try reusing the port
> number when reconnecting over TCP... any thoughts on that?

Why?
You would not be able to reconnect until the TCP timeout on connection
re-use has passed, and by that time any benefit that you might gain is
probably lost.
How does the TCP timeout compare with the replay-cache timeout??

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
