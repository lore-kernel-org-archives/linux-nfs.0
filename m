From: Rudi Starcevic <tech@wildcash.com>
Subject: Re: time_out_leases + 2.6 problem?
Date: Thu, 18 May 2006 15:13:47 +1000
Message-ID: <446C028B.2040605@wildcash.com>
References: <446916B1.8040202@wildcash.com> <17513.7432.642102.868775@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fgapn-0003yN-Dz
	for nfs@lists.sourceforge.net; Wed, 17 May 2006 22:14:03 -0700
Received: from mail1.mailhostingservice.com ([216.154.198.171])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1Fgapl-00074F-VJ
	for nfs@lists.sourceforge.net; Wed, 17 May 2006 22:14:03 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <17513.7432.642102.868775@cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Hi,

> Servers also seem to be using the user-space nfs server.  What this
> intentional?  If so, why?
> If not, try install nfs-kernel-server and using that instead.  It is
> likely to work better.
I'm not intentionaly using the nfs-user-server.

I've setup nfs-kernel-server on the problem machine and will roll
out nfs-kernel-server acrosss the other 15.
>>Would upgrading to a new kernel help this?
> 
> Given how old 2.6.8 is, and upgrade is certainly worth a try.

Am using 2.6.16, latest, kernel too.

Thanks very much for the advise.

-- 
Thank you.
Regards,
Rudi



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
