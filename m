From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFSD seems to stall
Date: Fri, 28 Jun 2002 07:10:59 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15643.32611.262001.494502@notabene.cse.unsw.edu.au>
References: <F888C30C3021D411B9DA00B0D0209BE8038F959D@cvo-exchange.cvo.roguewave.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17NgWV-0003Gg-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Jun 2002 14:09:51 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <petersp@roguewave.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 28 Jun 2002 07:09:36 +1000
To: Poul Petersen <petersp@roguewave.com>
In-Reply-To: message from Poul Petersen on Thursday June 27
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

On Thursday June 27, petersp@roguewave.com wrote:
> 
> Error 5: "/package/1/compilers/hp/aCC333/opt/aCC/include_std/rw/rwlocale",
> line 745 # Unable to open file
> /package/1/compilers/hp/aCC333/opt/aCC/include_std/rw/vendor; Connection
> timed out (238).

"Connection timed out" messages shouldn't be propagated up to
userspace by the NFS client.... unless you are using "soft" mounts.
You aren't doing that are you?  Please say you aren't

>                                  That space is served up using LVM 1.0.4 and
> ext3, though we saw the problem back in our XFS days as well. 


I have seen exactly these symptoms being due to ext3 bugs.  The bugs
have been present for a while, but seem to manifest more in 2.4.18.

The patch Andrew Morton posted at
  http://www.redhat.com/mailing-lists/ext3-users/msg03635.html

should fix it for you.  Maybe XFS has a similar problem... maybe it
was a totally different problem that time.

NeilBrown


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
