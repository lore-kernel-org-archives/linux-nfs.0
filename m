From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: Does mountd/statd really need to listen on a privileged
	port??
Date: Tue, 17 Apr 2007 12:08:51 +0200
Message-ID: <200704171208.51797.olaf.kirch@oracle.com>
References: <17950.44333.118970.276558@notabene.brown>
	<4623BCD9.3090501@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hdkdf-00060e-48
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 03:10:19 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hdkdg-0000rb-DP
	for nfs@lists.sourceforge.net; Tue, 17 Apr 2007 03:10:21 -0700
In-Reply-To: <4623BCD9.3090501@RedHat.com>
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

On Monday 16 April 2007 20:13, Steve Dickson wrote:
> > But is there some reason that mountd/statd need a priv port that I
> > haven't thought of?
> I don't think so... since neither mountd or statd checks to see
> if the source port is a priv port, its not clear why they should
> listen on one...

I think portmap let's joe doe replace registrations for non-privileged
ports. Joe Doe can't do that if the port is < 1024.

Denial of service is obvious. The bad things you can do by spoofing
file handles are probably even more interesting: "You want to
mount /diskless/root123? Here, try /home/okir/boobytrapped instead"

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
