From: Edward Hibbert <EH@dataconnection.com>
Subject: RE: Linux client, SNAP filer, ESTALE
Date: Wed, 28 May 2003 16:20:59 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFCD2C778CF1D611B5B400065B04D5C84A71B0@KENTON>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp.dataconnection.com ([192.91.191.4] helo=coltrane.dataconnection.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19L2jv-0005KZ-00
	for <nfs@lists.sourceforge.net>; Wed, 28 May 2003 08:21:19 -0700
To: 'James Pearson' <james-p@moving-picture.com>
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

Sorry, I should have been clearer.  Snap Appliance.

Regards,

Edward Hibbert
Internet Applications Group
Data Connection Ltd
Tel:	+44 131 662 1212		Fax:	+44 131 662 1345
Email:	eh@dataconnection.com	Web:	http://www.dataconnection.com

-----Original Message-----
From: James Pearson [mailto:james-p@moving-picture.com]
Sent: Wednesday, May 28, 2003 4:16 PM
To: Edward Hibbert
Cc: 'nfs@lists.sourceforge.net'
Subject: Re: [NFS] Linux client, SNAP filer, ESTALE


Is a 'SNAP filer' a NAS box from Snap Appliance or a NetApp filer?

James Pearson

Edward Hibbert wrote:
> 
> I have an ESTALE problem.  That probably means it's been discussed to
death,
> but after browsing the archive I'm not much the wiser, so...
> 
> Here's the scenario:
> *       RH 7.2 running a 2.4.18 kernel
> *       Linux boxes acting as NFS clients to a SNAP filer.
> *       Mount options rw,noac,rsize=4096,wsize=4096,hard,intr,bg
> 
> We had a power outage on the filer; the clients stayed up.  The clients
> returned stale errors, even once the filer had come back up, until we
> unmounted and remounted all the mount points.
> 
> Is this behaviour as expected, a known problem, an unknown problem, or too
> sloppily described to be able to tell?
> 
> Regards,
> 
> Edward Hibbert
> Internet Applications Group
> Data Connection Ltd
> Tel:    +44 131 662 1212                Fax:    +44 131 662 1345
> Email:  eh@dataconnection.com   Web:    http://www.dataconnection.com
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: ObjectStore.
> If flattening out C++ or Java code to make your application fit in a
> relational database is painful, don't do it! Check out ObjectStore.
> Now part of Progress Software. http://www.objectstore.net/sourceforge
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
