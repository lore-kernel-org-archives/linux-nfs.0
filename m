From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: Hanging udev process on nfs-mounted /dev
Date: Tue, 28 Sep 2004 17:56:47 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200409281756.50595.bernd-schubert@web.de>
References: <41592550.5060006@bio.ifi.lmu.de> <200409281359.21360.bernd-schubert@web.de> <415976DF.8020502@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CCKLa-0005i9-S9
	for nfs@lists.sourceforge.net; Tue, 28 Sep 2004 08:56:58 -0700
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CCKLZ-0005ok-4J
	for nfs@lists.sourceforge.net; Tue, 28 Sep 2004 08:56:58 -0700
Received: from euklid.pci.uni-heidelberg.de (euklid.pci.uni-heidelberg.de [129.206.21.104])
	by relay.uni-heidelberg.de (8.12.10/8.12.10) with ESMTP id i8SFup4i012726
	for <nfs@lists.sourceforge.net>; Tue, 28 Sep 2004 17:56:51 +0200 (MET DST)
Received: from bernd by euklid.pci.uni-heidelberg.de with local (Exim 3.35 #1 (Debian))
	id 1CCKLS-00020q-00
	for <nfs@lists.sourceforge.net>; Tue, 28 Sep 2004 17:56:50 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <415976DF.8020502@bio.ifi.lmu.de>
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

On Tuesday 28 September 2004 16:36, Frank Steiner wrote:
> Bernd Schubert wrote
>
> > Hello Frank,
> >
> > stupid question, udev always uses tmpfs, doesn't it?
>
> Hmm, I don't know. On the normal hosts (non diskless), I have tmpfs
> mounted at /dev/shm, but /dev itself is on the normal filesystem.
> And when I call e.g. "pktsetup mycd /dev/cdrecorder", udev creates
> e.g. /dev/pktcdvd0 which did not exist before.
> So I guess this is a normal device in the /dev directory and not related
> to tmpfs?
>
> However, I now wonder if I couldn't use a tmpfs for /dev for the clients.=
=2E.
> hmm...

On debian the udev init script always mounts /dev as tmpfs and as far as I=
=20
know this is the intended behaviour from the udev author.


Cheers,
	Bernd

=2D-=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
