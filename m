From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Problems with hard links in root NFS filesystem
Date: Thu, 1 Aug 2002 22:01:05 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15689.8961.389494.783003@notabene.cse.unsw.edu.au>
References: <F418066D6DFA5040A1169F0B39B7604A0DE23D@rg273.reliance.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17aEdJ-00029h-00
	for <nfs@lists.sourceforge.net>; Thu, 01 Aug 2002 05:00:45 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <DMB@reliance.co.uk>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Thu, 1 Aug 2002 22:00:30 +1000
To: Donald Burns <DMB@reliance.co.uk>
In-Reply-To: message from Donald Burns on Thursday August 1
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

On Thursday August 1, DMB@reliance.co.uk wrote:
> 				
> Dear list members,
> 
> I have a problem using NFS.
> 
> Synopsis:	Files that are hard linked on the server's root
> 		NFS images for a Beowulf cluster become inaccesable
> 		either imediately or after a few hours.

At a guess, I'd say "add the no_subtree_check option to your exports"
is the way to go.

NeilBrown



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
