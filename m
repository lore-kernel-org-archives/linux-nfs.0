From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: Multiple heterogeneous NFS servers on one machine
Date: Mon, 29 May 2006 21:51:40 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0605292150330.14964@maggie.lkpg.cendio.se>
References: <20060529182400.GQ13353@chiark.greenend.org.uk>
 <Pine.LNX.4.64.0605292046470.13557@maggie.lkpg.cendio.se>
 <20060529191851.GC30710@chiark.greenend.org.uk> <200605292136.16422.bernd-schubert@gmx.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1218340398-1148932298=:14964"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FknmJ-0004Cg-Hh
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 12:51:51 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FknmJ-0001II-Fy
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 12:51:51 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FknmI-0001Zk-Al
	for nfs@lists.sourceforge.net; Mon, 29 May 2006 12:51:51 -0700
To: Bernd Schubert <bernd-schubert@gmx.de>
In-Reply-To: <200605292136.16422.bernd-schubert@gmx.de>
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

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-1218340398-1148932298=:14964
Content-Type: TEXT/PLAIN; CHARSET=iso-8859-1; FORMAT=flowed
Content-ID: <Pine.LNX.4.64.0605292151391.14964@maggie.lkpg.cendio.se>
Content-Transfer-Encoding: quoted-printable

On Mon, 29 May 2006, Bernd Schubert wrote:

>> At this point I gave up with unfs3.  Any suggestions as to why that er=
ror
>> is happening?
>
> Anything in the logs of the Server? If the problem persist, can you cou=
ld
> start unfsd with '-p', so that it does't detach from the terminal.

That's the '-d' option.

Regards,
--=20
Peter =C5strand		ThinLinc Chief Developer
Cendio			http://www.cendio.se
Teknikringen 3
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-1218340398-1148932298=:14964--


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
