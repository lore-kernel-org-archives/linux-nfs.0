From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: address for lockd recovery
Date: Tue, 25 Jan 2005 22:26:36 -0800
Message-ID: <1106720796.10014.10.camel@lade.trondhjem.org>
References: <20050125091649.70886.qmail@web51605.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ctgdf-00026S-VI
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 22:26:51 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Ctgde-00085R-EQ
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 22:26:51 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050125091649.70886.qmail@web51605.mail.yahoo.com>
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

ty den 25.01.2005 Klokka 01:16 (-0800) skreiv mehta kiran:
> Hi , 
>      When i was checking lockd recovery , 
>      i noted that clients after getting
>      notification messages , use mon_id
>      as destination address and not notication
>      messages's source address as destination
>      address.(as just a reply)
> 
>      Is there any issue in using notifcation
>      messages's source address as destination
>      address to reclaim lock. ?

If you have a multi-homed server, it does not follow that the source
address used by rpc.statd hosts the same NFS server as the mon_name
address.

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
