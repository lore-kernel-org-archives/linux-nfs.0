From: "Isabelle, Francois" <Francois.Isabelle@ca.kontron.com>
Subject: RE: File modification bug (mismatch with stat)
Date: Fri, 7 Nov 2003 12:35:20 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5009AD9521A8D41198EE00805F85F18F039D3C59@sembo111.teknor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
	"David Roy-Moder (E-mail)" <david.roy-moder@intel.com>,
	"Ryan. J. Kummet (E-mail)" <ryan.j.kummet@intel.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AIAW8-0001lM-00
	for <nfs@lists.sourceforge.net>; Fri, 07 Nov 2003 09:35:28 -0800
Received: from [205.205.44.10] (helo=sembo111.teknor.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AIAW7-00035c-W2
	for nfs@lists.sourceforge.net; Fri, 07 Nov 2003 09:35:28 -0800
To: 'Trond Myklebust' <trond.myklebust@fys.uio.no>, "Isabelle, Francois"
	 <Francois.Isabelle@ca.kontron.com>
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

Exacly

Francois Isabelle
Francois.Isabelle@ca.kontron.com
Concepteur de logiciel
Software designer 
Kontron Canada


>-----Original Message-----
>From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
>Sent: 7 novembre, 2003 12:22
>To: Isabelle, Francois
>Cc: 'nfs@lists.sourceforge.net'; David Roy-Moder (E-mail); Ryan. J.
>Kummet (E-mail)
>Subject: Re: [NFS] File modification bug (mismatch with stat)
>
>
>>>>>> " " == Francois Isabelle <Isabelle> writes:
>
>     > Size : 9586 , time: 1068133738 <= Real time Size : 9586 , time:
>     > 1068141476 <= Time got higher for a little while Size : 9586 ,
>     > time: 1068141476 Size : 9586 , time: 1068141476 Size : 9586 ,
>     > time: 1068133738 <= Time got back to normal on file
>
>     > All calls to 'stat' occured in the same second.
>
>I assume nobody was writing to the file at the time (either on the
>client or the server)?
>
>Cheers,
>  Trond
>


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
