From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: DoS lockd
Date: Thu, 19 Sep 2002 09:49:49 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15753.4381.953349.672210@notabene.cse.unsw.edu.au>
References: <200209182342.g8INgWl112565@milan.maths.usyd.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17roZx-0006XQ-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Sep 2002 16:49:58 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.132] == wireless-132.wireless.cse.unsw.EDU.AU)
	(for <psz@maths.usyd.edu.au>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Thu, 19 Sep 2002 09:49:49 +1000
To: psz@maths.usyd.edu.au (Paul Szabo)
In-Reply-To: message from Paul Szabo on Thursday September 19
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

On Thursday September 19, psz@maths.usyd.edu.au wrote:
> Neil,
> 
> >> A Tru64 client may accidentally crash the lockd process on a Debian server.
> >> I wonder if this "works" on other Linux versions, and if this attack may be
> >> exploited to more than a DoS.
> > Looks like Trond submitted a fix for this on 10th July this year.
> 
> Thanks for your reply. However, could you please point me to this patch as
> I cannot find it?

http://linux.bkbits.net:8080/linux-2.4/cset@1.555.4.8

If you plug the subject line into google, it doesn't find any mailing
items, so maybe it was send directly to Macelo.

NeilBrown


-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
