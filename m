From: Arnaud Giersch <arnaud.giersch@free.fr>
Subject: Re: nfssvc: writting fds to kernel failed: errno 0 (Success)
Date: Mon, 12 Feb 2007 01:42:56 +0100
Message-ID: <87abzk5hpr.fsf@groumpf.homeip.net>
References: <87fy9c5m0l.fsf@groumpf.homeip.net>
	<17871.43333.241970.724805@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGPHY-00051Q-RN
	for nfs@lists.sourceforge.net; Sun, 11 Feb 2007 16:43:00 -0800
Received: from smtp4-g19.free.fr ([212.27.42.30])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HGPHY-0008Fa-FY
	for nfs@lists.sourceforge.net; Sun, 11 Feb 2007 16:43:02 -0800
In-Reply-To: <17871.43333.241970.724805@notabene.brown> (Neil Brown's message
	of "Mon, 12 Feb 2007 10:39:49 +1100")
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

Lundi 12 f=E9vrier 2007, vers 00:39:49 (+0100), Neil Brown a =E9crit:

> On Monday February 12, arnaud.giersch@free.fr wrote:
>> Feb 11 21:46:23 bilbo nfsd[18672]: nfssvc: writting fds to kernel failed=
: errno 0 (Success)
[...]
> The following kernel patch should stop the error (and a separate patch
> will fix the typo in the error message...)

Thanks.  The patch looks ok to me, but I am sorry I can't test it for
the moment.  =


The machines running an NFS server that I have access to are either
our main server at work, or my old home server which takes several
hours to build a new kernel.

        Arnaud Giersch

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easi=
er.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D120709&bid=3D263057&dat=3D1=
21642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
