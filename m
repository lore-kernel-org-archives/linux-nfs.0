From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: DoS lockd
Date: Wed, 18 Sep 2002 17:25:07 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15752.10835.180301.420321@notabene.cse.unsw.edu.au>
References: <200209180137.g8I1bQf87489@milan.maths.usyd.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rbHh-0008J4-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Sep 2002 02:38:13 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <psz@maths.usyd.edu.au>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 18 Sep 2002 19:38:05 +1000
To: psz@maths.usyd.edu.au (Paul Szabo)
In-Reply-To: message from Paul Szabo on Wednesday September 18
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Wednesday September 18, psz@maths.usyd.edu.au wrote:
> A Tru64 client may accidentally crash the lockd process on a Debian server.
> I wonder if this "works" on other Linux versions, and if this attack may be
> exploited to more than a DoS.
> 
> Any followups/replies please send me directly, as I am not subscribed to
> the nfs@lists.sourceforge.net mailing list.

Looks like Trond submitted a fix for this on 10th July this year.

NeilBrown


-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
