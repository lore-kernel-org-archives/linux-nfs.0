From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: async vs. sync
Date: Tue, 27 Jul 2004 17:07:30 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407271707.31487.bernd-schubert@web.de>
References: <482A3FA0050D21419C269D13989C61130435E530@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpTYL-0003t3-It
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 08:07:41 -0700
Received: from smtp05.web.de ([217.72.192.209])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BpTYL-0008Cj-0o
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 08:07:41 -0700
To: "Lever, Charles" <cel@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435E530@lavender-fe.eng.netapp.com>
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

On Tuesday 27 July 2004 16:16, you wrote:
> bernd-
>
> you didn't mention how many server processes were running.  if the
> server load goes up to 8, then i would guess you have only 8.  you
> should probably boost it to a much larger number, like 128 or more.

Currently 64, top usually shows a usuage between 1 and 10, but not more. I can 
try to increase it 128 or more in the evening to see if it helps to speed up 
sync mounts.


Cheers,
	Bernd



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
