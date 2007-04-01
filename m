From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: RELEASE CANDIDATE - nfs-utils-1.1.0-rc1
Date: Sun, 1 Apr 2007 14:04:38 +0200
Message-ID: <20070401120438.GA26681@janus>
References: <17931.15549.578071.112573@notabene.brown>
	<20070329084433.GA1627@sith.mimuw.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Jan Rekorajski <baggins@sith.mimuw.edu.pl>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HXyna-0000sm-RX
	for nfs@lists.sourceforge.net; Sun, 01 Apr 2007 05:04:44 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HXynZ-0001s6-M4
	for nfs@lists.sourceforge.net; Sun, 01 Apr 2007 05:04:45 -0700
In-Reply-To: <20070329084433.GA1627@sith.mimuw.edu.pl>
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

On Thu, Mar 29, 2007 at 10:44:33AM +0200, Jan Rekorajski wrote:
> On Thu, 29 Mar 2007, Neil Brown wrote:
> 
> >  Run "statd" only when starting the NFS server.
> >  "statd" should be run before starting the NFS server.
> 
> While you're at it, can you tell me what should be the order of starting
> all NFS/NFS4 daemons? So far I got to this:
> 
> 1) statd
> 2) mountd
> 3) nfsd
> 4) idmapd
> 5) svcgssd
> 6) gssd
> 7) rquotad
> 8) any NFS mounts
> 

It would be a good idea to put the final answer in a FAQ.

-- 
Frank

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
