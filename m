From: "William A.(Andy) Adamson" <andros@citi.umich.edu>
Subject: Re: NFSv4 stability: export unused a night
Date: Tue, 10 Feb 2004 11:22:57 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040210162257.CAD7A20814@citi.umich.edu>
References: <200402051713.33948.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	andros@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AqafC-0008PM-2O
	for nfs@lists.sourceforge.net; Tue, 10 Feb 2004 08:23:06 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1Aqaeg-0005Pw-9k
	for nfs@lists.sourceforge.net; Tue, 10 Feb 2004 08:22:34 -0800
To: vincent.roqueta@ext.bull.net
In-reply-to: Your message of "Thu, 05 Feb 2004 17:13:33 +0100."
             <200402051713.33948.vincent.roqueta@ext.bull.net>
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

hi

thanks for the bug report. i am looking at nfsv4 nfsd reboot recovery thi=
s =

week, and will specifically note your bug...

-->Andy


> Le Jeudi 05 F=E9vrier 2004 14:07, Vincent ROQUETA a =E9crit :
> > 1/
> >
> > When I lived yesterday server computer test was up, configured with 1=

> > export partition.
> > This export was moutable from the client side.
> >
> > Threre was no reboot of the server this night.
> > This morning, I was unable to mount the exported directory.
> >
> > After reboot, all was OK.
> =

> More precisions. I have reproduced the bug:
> =

> 1/ Server up, client up
> 2/ client mount a nfs4 fs.
> 3/ reboot client (without umounting )
> 4/ Client can't mount nfs , server answer: permission denied
> =

> =

> More... If I kill all nfsd and  mountd and reload them, there is still =
this =

> problem. I need to reboot the server
> =

> =

> =

> =

> -------------------------------------------------------
> The SF.Net email is sponsored by EclipseCon 2004
> Premiere Conference on Open Tools Development and Integration
> See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
> http://www.eclipsecon.org/osdn
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> =





-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
