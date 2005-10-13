From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS security
Date: Thu, 13 Oct 2005 08:43:43 -0400
Message-ID: <1129207423.8578.3.camel@lade.trondhjem.org>
References: <f872993a0510130004p90cb2eal3dd17d58b892083d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EQ2Rf-0004Mc-IK
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 05:44:27 -0700
Received: from pat.uio.no ([129.240.130.16])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EQ2Re-0001iK-AU
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 05:44:27 -0700
To: Raghu R <roverphoenix@gmail.com>
In-Reply-To: <f872993a0510130004p90cb2eal3dd17d58b892083d@mail.gmail.com>
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

to den 13.10.2005 Klokka 00:04 (-0700) skreiv Raghu R:
> Hi guys,
> 
> I am a newbie at sourceforge and I need some help regarding a project
> topic I would like to do provide GAA-API/kerberos support into NFS(I
> obviously would not be able to provide all the features eg n/w with
> bridges etc), I would like to get some feedback as to the scope of it,
> I am planning to do it alone and have a time frame of about 2 months,
> I am very comfortable with C/C++ and linux architecture.

Since we already have GSS_API support, I assume that your project would
mainly be to add all the support for the EACL stuff?
Could you please outline how you propose to implement this? I'm not
aware of any GAA-API implementations for RPC or NFS.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
