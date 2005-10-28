From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS: Access Denied after Sever Reboot (on 2.6)
Date: Fri, 28 Oct 2005 10:36:33 -0400
Message-ID: <1130510193.8815.37.camel@lade.trondhjem.org>
References: <DCEAAC0833DD314AB0B58112AD99B93BA3007B@ismail.innsys.innovsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EVVLj-0006an-T8
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 07:36:55 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EVVLg-0004oS-Ju
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 07:36:52 -0700
To: Shane Warren <shanew@innovsys.com>
In-Reply-To: <DCEAAC0833DD314AB0B58112AD99B93BA3007B@ismail.innsys.innovsys.com>
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

fr den 28.10.2005 klokka 09:17 (-0500) skreiv Shane Warren:
> I have packet sniffed (w/ tcpdump and loading the dump in ethereal)
> the messages the server gets/sends when the client gets the "access
> denied" (when listing the shared directory), the exchange is something
> like:
>  
> client sends: GETATTR on a certain inode with authentication set to:
> none
> server responds: reject state set to: AUTH_ERROR, auth state set to:
> Bad Credential (seal broken)

Could you send me a binary tcpdump of this exchange, please? The client
should never be sending anything with an AUTH_NULL credential.

As for the server issue, have you checked that the 'nfsd' filesystem is
being properly mounted, and that none of the scripts are calling
exportfs after mountd has started?

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
