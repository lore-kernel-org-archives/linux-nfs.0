From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: address for lockd recovery
Date: Wed, 26 Jan 2005 02:20:14 -0800 (PST)
Message-ID: <20050126102014.90997.qmail@web51601.mail.yahoo.com>
References: <1106720796.10014.10.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtkHh-0005FE-6k
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 02:20:25 -0800
Received: from web51601.mail.yahoo.com ([206.190.38.206])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1CtkHf-0006Py-KI
	for nfs@lists.sourceforge.net; Wed, 26 Jan 2005 02:20:25 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <1106720796.10014.10.camel@lade.trondhjem.org>
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

thanks Trond.
           What i could get from  this statement is
that source address and mon_id in notification
message cannot be guaranteed to belong to same
machine. 
But two different machines can have same
mon_id(nfs never pings mon_id , mon_ids can be faked)
but will have different source address.so doesn't
source address of notification message  uniquely
isentify nfs server rather than mon_id and
hence safe to reclaim locks.

--thanks
   kiran

--- Trond Myklebust <trond.myklebust@fys.uio.no>
wrote:

> ty den 25.01.2005 Klokka 01:16 (-0800) skreiv mehta
> kiran:
> > Hi , 
> >      When i was checking lockd recovery , 
> >      i noted that clients after getting
> >      notification messages , use mon_id
> >      as destination address and not notication
> >      messages's source address as destination
> >      address.(as just a reply)
> > 
> >      Is there any issue in using notifcation
> >      messages's source address as destination
> >      address to reclaim lock. ?
> 
> If you have a multi-homed server, it does not follow
> that the source
> address used by rpc.statd hosts the same NFS server
> as the mon_name
> address.
> 
> Cheers,
>   Trond
> -- 
> Trond Myklebust <trond.myklebust@fys.uio.no>
> 
> 



	
		
__________________________________ 
Do you Yahoo!? 
Yahoo! Mail - You care about security. So do we. 
http://promotions.yahoo.com/new_mail


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
