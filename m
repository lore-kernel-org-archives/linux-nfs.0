From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: Hanging udev process on nfs-mounted /dev
Date: Wed, 29 Sep 2004 08:00:06 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <415A4F66.3070201@bio.ifi.lmu.de>
References: <41592550.5060006@bio.ifi.lmu.de> <200409281359.21360.bernd-schubert@web.de> <415976DF.8020502@bio.ifi.lmu.de> <200409281756.50595.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CCXVb-00070w-Ax
	for nfs@lists.sourceforge.net; Tue, 28 Sep 2004 23:00:11 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CCXVZ-0005Ji-DG
	for nfs@lists.sourceforge.net; Tue, 28 Sep 2004 23:00:11 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200409281756.50595.bernd-schubert@web.de>
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

Bernd Schubert wrote

> On debian the udev init script always mounts /dev as tmpfs and as far as I 
> know this is the intended behaviour from the udev author.

Looks like SuSE is not doing this. But actually, it could be a solution
for my problem! Thanks for the hint!
Anyway, would be interesting to know if this is a NFS bug or not, just
to avoid stepping over it later :-)

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
