From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: Hanging udev process on nfs-mounted /dev
Date: Tue, 28 Sep 2004 16:36:15 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <415976DF.8020502@bio.ifi.lmu.de>
References: <41592550.5060006@bio.ifi.lmu.de> <200409281359.21360.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CCJ5V-0000eQ-OA
	for nfs@lists.sourceforge.net; Tue, 28 Sep 2004 07:36:17 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CCJ5V-00085g-0y
	for nfs@lists.sourceforge.net; Tue, 28 Sep 2004 07:36:17 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200409281359.21360.bernd-schubert@web.de>
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

> Hello Frank,
> 
> stupid question, udev always uses tmpfs, doesn't it? 

Hmm, I don't know. On the normal hosts (non diskless), I have tmpfs
mounted at /dev/shm, but /dev itself is on the normal filesystem.
And when I call e.g. "pktsetup mycd /dev/cdrecorder", udev creates
e.g. /dev/pktcdvd0 which did not exist before.
So I guess this is a normal device in the /dev directory and not related
to tmpfs?

However, I now wonder if I couldn't use a tmpfs for /dev for the clients...
hmm...

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
