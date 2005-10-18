From: Sven Geggus <sven-im-usenet@gegg.us>
Subject: Re: Authenticated NFS mounts
Date: Tue, 18 Oct 2005 11:29:06 +0000 (UTC)
Message-ID: <dj2ma2$52v$1@benzin.geggus.net>
References: <dj2kkn$4hr$1@benzin.geggus.net> <200510181313.09401.vincent.roqueta@ext.bull.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERpee-00050c-3a
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 04:29:16 -0700
Received: from dolly.gnuher.de ([212.227.64.154])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ERpeZ-00033c-Ps
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 04:29:13 -0700
Received: from benzin.geggus.net ([2001:8d8:81:672::1])
	by dolly.gnuher.de with esmtpsa TLS-1.0:RSA_AES_256_CBC_SHA:32
	(Exim 4.50 id 1ERpeV-0002w5-A8)
	for <nfs@lists.sourceforge.net>; Tue, 18 Oct 2005 13:29:07 +0200
Received: from news by benzin.geggus.net with local
	(Exim 4.50 id 1ERpeU-0001Pw-8s)
	for <nfs@lists.sourceforge.net>; Tue, 18 Oct 2005 13:29:06 +0200
To: nfs@lists.sourceforge.net
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

Vincent Roqueta <vincent.roqueta@ext.bull.net> wrote:

>> Is ist possible to use RPCSEC GSSAPI in conjunction with NFSv3 on Linux
>> Clients and Servers?
> Yes, that is possible.

Any kind of mini HOWTO on this? Which Versions of mount, nfs-utils etc would
I need?

Protection against mounts from untrusted machines which are not
authenticated is all I need to provide at the Moment.

NFSv4 seems to be a better design, but stability is more important for my
application.

Sven

-- 
"Software is like sex; it's better when it's free"
	                              (Linus Torvalds)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
