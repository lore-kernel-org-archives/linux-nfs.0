From: Stefan Palme <kleiner@hora-obscura.de>
Subject: Re: userid mapping
Date: Tue, 04 Oct 2005 17:19:03 +0200
Message-ID: <1128439143.2465.33.camel@devel.office.ancoso-development.de>
References: <1128375383.26373.4.camel@blackmamba.kapott.org>
	 <4341A7B9.5060109@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EMoZb-0008ID-Lj
	for nfs@lists.sourceforge.net; Tue, 04 Oct 2005 08:19:19 -0700
Received: from 213-239-198-170.clients.your-server.de ([213.239.198.170] helo=ancoso-development.de)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EMoZW-0004Oa-Ku
	for nfs@lists.sourceforge.net; Tue, 04 Oct 2005 08:19:19 -0700
Received: from localhost (localhost [127.0.0.1])
	by linux.ancoso-development.de (Postfix) with ESMTP id AEF974A499
	for <nfs@lists.sourceforge.net>; Tue,  4 Oct 2005 17:19:05 +0200 (CEST)
Received: from ancoso-development.de ([127.0.0.1])
 by localhost (smtp.ancoso-development.de [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 21513-06 for <nfs@lists.sourceforge.net>;
 Tue,  4 Oct 2005 17:19:05 +0200 (CEST)
Received: from laus.ancoso-development.de (p54B982DD.dip0.t-ipconnect.de [84.185.130.221])
	by linux.ancoso-development.de (Postfix) with ESMTP id 6C56049ED5
	for <nfs@lists.sourceforge.net>; Tue,  4 Oct 2005 17:19:05 +0200 (CEST)
Received: from devel.office.ancoso-development.de (devel.office.ancoso-development.de [192.168.2.126])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by laus.ancoso-development.de (Postfix) with ESMTP id 6BE5E1CA47A
	for <nfs@lists.sourceforge.net>; Tue,  4 Oct 2005 17:19:04 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by devel.office.ancoso-development.de (Postfix) with ESMTP id E205E1FF165
	for <nfs@lists.sourceforge.net>; Tue,  4 Oct 2005 17:19:03 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <4341A7B9.5060109@redhat.com>
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

On Mon, 2005-10-03 at 17:50 -0400, Peter Staubach wrote:
> Stefan Palme wrote:
> >I guess this is a FAQ, but I have not found any information that
> >helped me out... I'm running a NFSv3-server and clients with linux
> >kernel 2.6.X. I have the same user-names on both client and server,
> >but different user-ids. Is it possible to establish a mapping between
> >the client's and server's userids? 
> 
> The usual suggestion is to set up Kerberos and use RPCSEC_GSS to
> pass the authentication information.

Won't this slow down the NFS-performance? Or is the security overhead
for kerberos "ignorable"?

Thanks
-Stefan-





-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
