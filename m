From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs_notify_change: revalidate_failed, error=-512
Date: 11 Mar 2003 19:34:26 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shswuj5iwgd.fsf@charged.uio.no>
References: <5CA6F03EF05E0046AC5594562398B916A32868@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18soaA-0006X2-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Mar 2003 10:34:34 -0800
To: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B916A32868@POEXMB3.conoco.net>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Roger A Heflin <Heflin> writes:

     > 	Hello,

     > 	I am getting the following error on the client end.

     > 	nfs_notify_change: revalidate_failed, error=-512

512 == ERESTARTSYS => somebody pressed Ctrl-C while the process was in
the middle of the RPC call. Should be no big deal...

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
