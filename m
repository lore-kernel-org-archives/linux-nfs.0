From: Olaf Kirch <okir@lst.de>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Wed, 25 Apr 2007 13:56:35 +0200
Message-ID: <200704251356.35926.okir@lst.de>
References: <17958.48121.280256.493824@notabene.brown>
	<462E6812.6040401@RedHat.com> <462E6A54.1010709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HggkV-0006mt-7V
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 05:37:31 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HggkW-0002Oj-9m
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 05:37:33 -0700
Received: from [192.168.5.32] (p54A7CBAB.dip.t-dialin.net [84.167.203.171])
	(authenticated bits=0)
	by mail.lst.de (8.12.3/8.12.3/Debian-7.1) with ESMTP id l3PCbRLD027180
	(version=TLSv1/SSLv3 cipher=EXP1024-RC4-SHA bits=56 verify=NO)
	for <nfs@lists.sourceforge.net>; Wed, 25 Apr 2007 14:37:29 +0200
In-Reply-To: <462E6A54.1010709@redhat.com>
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

On Tuesday 24 April 2007 22:36, Peter Staubach wrote:
> I don't think that I understand why being bug for bug compatible with
> the current glibc code is interesting.  This is a new version of the

Well, you don't want to re-introduce bugs that have been fixed in
glibc ages ago, right? Especially when it comes to security issues
and thread safety.

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
