From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Sun, 29 Apr 2007 19:32:32 -0400
Message-ID: <46352B10.2070806@RedHat.com>
References: <17958.48121.280256.493824@notabene.brown>	<17968.18279.424773.589417@notabene.brown>	<200704261059.50688.okir@lst.de>
	<200704271707.29862.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Olaf Kirch <okir@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiIrp-0007fi-Nv
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 16:31:45 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiIrr-0007Wf-64
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 16:31:48 -0700
In-Reply-To: <200704271707.29862.okir@lst.de>
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

Olaf Kirch wrote:
> 
> It hasn't seen much testing; I just confirmed that it still seems to
> work with IPv4. The IPv6 side hasn't seen any testing yet.
> 
> Please consider this as a proof of concept.
I'm very curious.... why is there such a love affair with the glibc
code?  Its one of the oldest version running.. it has not been
well maintained (basically because it couldn't be)... The code has
compatible issues when apps are ported to it (I have bugs to prove
that)...  so why is there such a reverence for code that can arguably be 
called a lesser implementation?

As far as moving the glibc into a stand alone library, I not
sure how that sense either... I guess the idea is to take the old
code and added in a new network stack resulting in pile of code that has
zero amount testing... verses going with time tested
code that is known to work but does have couple of issues...

 From a risk management point of view, it seems to me the latter is
heads and shoulders above the former... so again, why does it make
sense to do this?

steved.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
