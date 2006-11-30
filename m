From: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
Subject: Re: Terrible performance between 2.6.16 and 2.6.5
Date: Thu, 30 Nov 2006 16:18:11 +0100
Message-ID: <456EF633.9070106@bio.ifi.lmu.de>
References: <456EC5D1.9050008@bio.ifi.lmu.de> <456EE99A.90009@atipa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gpng2-0004Bg-JE
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 07:18:18 -0800
Received: from acheron.ifi.lmu.de ([129.187.214.135])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gpng1-0003x3-IG
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 07:18:20 -0800
To: Roger Heflin <rheflin@atipa.com>
In-Reply-To: <456EE99A.90009@atipa.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Roger Heflin wrote

> What is the type of the underlying disk subsystem?  Did the underlying
> disk subsystem's performance change or is it the same?   You may need
> to run bonnie or something similar to verify that the disk hardware
> is not where the issue is.

Not, that's the same external FC raid as before. But I will do
some local disk tests!

> I have seen the MPT driver in the later kernels be quite a bit
> slower (3x) with certain combinations of devices.
> 
> And there are a fair number of issues were various other disk
> devices from time to time get much slower in newer kernels, but
> are fine in older kernels.

I don't think it's the disk itself, because the SuSE 10.1/SLES 10
clients don't show this performance problem  when running the same
command on the same directories. Therefore I'm pretty sure that the
SLES 9 kernel has some issues with the newer NFS system in 2.6.16.

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
