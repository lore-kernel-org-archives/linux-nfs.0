From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Another bug....
Date: Tue, 10 Feb 2004 09:50:17 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040210145016.GA9608@fieldses.org>
References: <200402091601.48120.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AqZDU-0001s2-6X
	for nfs@lists.sourceforge.net; Tue, 10 Feb 2004 06:50:24 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1AqZD3-0004Y0-S5
	for nfs@lists.sourceforge.net; Tue, 10 Feb 2004 06:49:58 -0800
To: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
In-Reply-To: <200402091601.48120.vincent.roqueta@ext.bull.net>
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

On Mon, Feb 09, 2004 at 04:01:48PM +0100, Vincent ROQUETA wrote:
> I still not have understood the previous bug (mounting; rebooting without 
> umounting ; remounting) I found others bugs.
> 
> I was creating big big files with bonnie++.
> 
> I used vim to write "program.c" on a shared NFSv4 remote directory.
> 
> 
> -rw-r--r--    1 4294967294 4294967294        0 oct 31  1970 4913
> -rw-r--r--    1 4294967294 4294967294        0 nov  1  1970 5036
> -rw-r--r--    1 4294967294 4294967294        0 nov  1  1970 5159
> -rw-r--r--    1 4294967294 4294967294        0 nov  2  1970 5282
> -rwxr-xr-x    1 4294967294 4294967294    11326 fév  9  2004 program
> -rw-r--r--    1 4294967294 4294967294      136 fév  9  2004 program.c
> -rw-r--r--    1 4294967294 4294967294        0 oct 31  1970 program.c~
> -rw-r--r--    1 4294967294 4294967294        0 nov  2  1970 program.x~
> -rw-r--r--    1 4294967294 4294967294        0 nov  1  1970 program.y~
> -rw-r--r--    1 4294967294 4294967294        0 nov  1  1970 program.z~
> 
> 
> 
> Creating program.c, vim tell me that it found an old swaped file!
> (So I suppose when vim is trying to detect a swaped file, it CREATE this 
> file?)
> 
> Well... and for sure this file was not created in october/november 1970 !!!

Which kernel are you using, and which patches?--Bruce Fields


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
