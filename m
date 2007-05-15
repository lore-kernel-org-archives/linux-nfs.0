From: David Wuertele <dave-gmane@bfnet.com>
Subject: Re: What's up with those fractional-second mtimes?
Date: Tue, 15 May 2007 16:49:31 +0000 (UTC)
Message-ID: <loom.20070515T184657-859@post.gmane.org>
References: <loom.20070515T045905-915@post.gmane.org>
	<1179239524.6464.26.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ho0Dn-00059C-P5
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 09:50:03 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ho0Dp-0004tQ-9P
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 09:50:02 -0700
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Ho0Db-0006Ow-6L
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 18:49:47 +0200
Received: from wwwgate1.motorola.com ([129.188.69.129])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Tue, 15 May 2007 18:49:47 +0200
Received: from dave-gmane by wwwgate1.motorola.com with local (Gmexim 0.1
	(Debian)) id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Tue, 15 May 2007 18:49:47 +0200
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Dave> Can I disable fractional timestamps?  Can I enable proper
Dave> processing of them?

Trond> Sounds like a bug in 'cp'. Could you try using 'strace' to sniff if they
Trond> are really using the 'utimes()' call (rather than the 'utime()' call,
Trond> which only has a 1 second resolution) then sniff what they are sending
Trond> as arguments?

It is not just cp, it is gzip and several other commands (I doubt I could find
them all) which use utime() instead of utimes().

Since I don't have control over the tools available on the target, I would like
to just disable the fractional part of the timestamps altoghether, so that
utime() returns the same as utimes().

Is that possible?

Dave





-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
