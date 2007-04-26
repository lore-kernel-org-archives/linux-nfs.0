From: Olaf Kirch <okir@lst.de>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Thu, 26 Apr 2007 10:59:49 +0200
Message-ID: <200704261059.50688.okir@lst.de>
References: <17958.48121.280256.493824@notabene.brown>
	<200704252214.03069.okir@lst.de>
	<17968.18279.424773.589417@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hgzpd-0001cn-GB
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 02:00:05 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hgzpd-0001DC-Mz
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 02:00:08 -0700
In-Reply-To: <17968.18279.424773.589417@notabene.brown>
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

On Thursday 26 April 2007 08:32, Neil Brown wrote:
> Following this logic, should we add rpcbind functionality to portmap
> rather than throw it out and start with something less known???

I'm not sure. The rpcbind code isn't exactly pretty, but neither is
portmap.

Anyway, I guess in order to prove my point about the sunrpc library
I should cough up some code to prove it can be done. I'll be uploading
some patches later tonight or tomorrow.

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
