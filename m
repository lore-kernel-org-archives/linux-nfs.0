From: "Isabelle, Francois" <Francois.Isabelle@ca.kontron.com>
Subject: File modification bug (mismatch with stat)
Date: Fri, 7 Nov 2003 10:17:49 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5009AD9521A8D41198EE00805F85F18F039D3C55@sembo111.teknor.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "David Roy-Moder (E-mail)" <david.roy-moder@intel.com>,
	"Ryan. J. Kummet (E-mail)" <ryan.j.kummet@intel.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AI8N2-0000M1-00
	for <nfs@lists.sourceforge.net>; Fri, 07 Nov 2003 07:17:56 -0800
Received: from [205.205.44.10] (helo=sembo111.teknor.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AI8N1-0004Hb-NU
	for nfs@lists.sourceforge.net; Fri, 07 Nov 2003 07:17:55 -0800
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

There is an error in the "stuct stat: time of last modification" st_mtime
member when calling 'stat' on an NFS mounted file.

NFS server is a linux 2.4.21-pre5 SMP kernel with knfsd and nfs-utils 0.3.3
NFS client is a linux 2.4.20 and nfs-utils 1.0.3 

It can take quiet a while before it happens, but basically:

while true
{
'stat' the file to get it's last modification time
fopen it
read on it
close it
}

once upon a time , the modification time will vary as this log shows:

Size : 9586 , time: 1068133738  <= Real time
Size : 9586 , time: 1068141476  <= Time got higher for a little while
Size : 9586 , time: 1068141476  
Size : 9586 , time: 1068141476 
Size : 9586 , time: 1068133738  <= Time got back to normal on file

All calls to 'stat' occured in the same second.

Is there any known issues regarding this ? Or any special care to take when
using 'stat' on an NFS mounted drive ?

Thanks in advance


Francois Isabelle
Francois.Isabelle@ca.kontron.com
Concepteur de logiciel
Software designer 
Kontron Canada


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
