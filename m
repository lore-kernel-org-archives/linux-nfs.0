From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: NFS trace wish list?
Date: Mon, 14 Apr 2003 13:47:50 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0304141326230.21680-100000@kenzo.iwr.uni-heidelberg.de>
References: <Pine.BSF.4.51.0304101839050.72189@bowser.eecs.harvard.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1952RP-0007le-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Apr 2003 04:48:03 -0700
To: Daniel Ellard <ellard@eecs.harvard.edu>
In-Reply-To: <Pine.BSF.4.51.0304101839050.72189@bowser.eecs.harvard.edu>
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

On Thu, 10 Apr 2003, Daniel Ellard wrote:

> Here's where you can help.  I'm trying to put together a wish list of
> NFS analysis tools -- what tools would you like that you haven't got?

Some network related information to pinpoint problems with the network. 

For example, look at retransmits (there is only a system wide counter
available right now): if a server has lots of retransmits pretty equal
distributed among clients, this might indicate a problem with network
connection of the server or the network in general; if the retransmits
happen mostly to a reduced number of clients, the clients are most likely
at fault.
When retransmitting, lowering rsize/wsize might reduce retransmissions, 
while lowering the maximum transfer bandwidth. So, if some client has 
problems with retransmissions, check if another client which is behaving 
well has a lower rsize/wsize - if so, suggest lowering it to the same 
value also on the troubled client... (this probably means keeping track of 
a lot of data, so I don't know how feasible it is).

Another thing which might be useful is a measure of time for replies, to 
diagnose the "Can't get request slot" messages. If the server replies 
quickly it means the return path to the client is broken (that might mean 
even the network connection of the server, as the reply is seen before it 
gets in the transmit queue of the network driver). But if the server 
replies too slow, then the server is overloaded.

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
