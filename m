From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: Re: Another bug....
Date: Wed, 11 Feb 2004 09:22:21 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402110922.22087.vincent.roqueta@ext.bull.net>
References: <200402091601.48120.vincent.roqueta@ext.bull.net> <20040210145016.GA9608@fieldses.org>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AqpcD-0004o7-F0
	for nfs@lists.sourceforge.net; Wed, 11 Feb 2004 00:21:01 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aqpaj-00076d-W8
	for nfs@lists.sourceforge.net; Wed, 11 Feb 2004 00:19:30 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040210145016.GA9608@fieldses.org>
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

Le Mardi 10 F=E9vrier 2004 15:50, J. Bruce Fields a =E9crit :
> On Mon, Feb 09, 2004 at 04:01:48PM +0100, Vincent ROQUETA wrote:
> > I still not have understood the previous bug (mounting; rebooting witho=
ut
> > umounting ; remounting) I found others bugs.
> >
> > I was creating big big files with bonnie++.
> >
> > I used vim to write "program.c" on a shared NFSv4 remote directory.
> >
> >
> > -rw-r--r--    1 4294967294 4294967294        0 oct 31  1970 4913
> > -rw-r--r--    1 4294967294 4294967294        0 nov  1  1970 5036
> > -rw-r--r--    1 4294967294 4294967294        0 nov  1  1970 5159
> > -rw-r--r--    1 4294967294 4294967294        0 nov  2  1970 5282
> > -rwxr-xr-x    1 4294967294 4294967294    11326 f=E9v  9  2004 program
> > -rw-r--r--    1 4294967294 4294967294      136 f=E9v  9  2004 program.c
> > -rw-r--r--    1 4294967294 4294967294        0 oct 31  1970 program.c~
> > -rw-r--r--    1 4294967294 4294967294        0 nov  2  1970 program.x~
> > -rw-r--r--    1 4294967294 4294967294        0 nov  1  1970 program.y~
> > -rw-r--r--    1 4294967294 4294967294        0 nov  1  1970 program.z~
> >
> >
> >
> > Creating program.c, vim tell me that it found an old swaped file!
> > (So I suppose when vim is trying to detect a swaped file, it CREATE this
> > file?)
> >
> > Well... and for sure this file was not created in october/november 1970
> > !!!
>
> Which kernel are you using, and which patches?--Bruce Fields

My kernel is linux 2.6.2 without kernel patches...=20



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
