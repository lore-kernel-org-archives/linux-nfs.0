From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Fri, 16 Mar 2007 14:10:47 -0400
Message-ID: <20070316181047.GD4538@fieldses.org>
References: <17914.20117.186786.830574@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>,
	richterd@citi.umich.edu
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HSGt9-0007UH-G0
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 11:10:51 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HSGtA-0007Rn-66
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 11:10:53 -0700
In-Reply-To: <17914.20117.186786.830574@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, Mar 16, 2007 at 07:00:21PM +1100, Neil Brown wrote:
> Statd currently does several very different things.
> 1/ It listens for monitor requests from lockd and creates
>    files in /var/lib/nfs/sm/HOST
> 2/ It listens for notifications from peers and tells lockd
>    that those peers have restarted.
> 3/ It moves files from sm/ to sm.bak/ and then tries to 
>    notify every host listed in sm.bak/
> 
> The first is very similar to what NFSv4 needs for state management,
> though is somewhat simpler.  I would like to create a better
> interface for the kernel to ask for state to be stored, and then use
> if for NFSv4 and NLM, subsuming this function.

NFSv4 needs something like the third as well--knfsd needs to know on
startup the list of clients that will be allowed to reclaim state from a
previous boot instance.  (This is to protect clients that *think*
they're still holding locks on the server, but (thanks to a network
partition) don't realize that the server has actually rebooted twice.)

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
