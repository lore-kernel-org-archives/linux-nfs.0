From: Donavan Pantke <avatar@dcr.net>
Subject: Re: huge number of intr/s on large nfs server
Date: Wed, 16 Oct 2002 19:28:36 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200210161928.36801.avatar@dcr.net>
References: <CFEAJJEGMGECBCJFLGDBEELLCFAA.enorwood@effrem.com>
Reply-To: avatar@dcr.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.dcr.net ([216.7.64.2] helo=andrew.dcr.net)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 181xaM-0005WD-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Oct 2002 16:28:18 -0700
To: "Eff Norwood" <enorwood@effrem.com>, <nfs@lists.sourceforge.net>
In-Reply-To: <CFEAJJEGMGECBCJFLGDBEELLCFAA.enorwood@effrem.com>
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

On Wednesday 16 October 2002 19:18, Eff Norwood wrote:
> > =09Umm... just a small interjection, but can't you just pass
> > the parameters
> > through LILO or GRUB?
>
> That's an *excellent* suggestion. I had forgotten you could do that! So
> yes, everything can be built into the kernel. Anyone know of a good how=
to
> on this subject?

=09Umm... stadard linuxdoc.org should have one, but real quick, in LILO i=
t=20
involves this:

append=3D"eth0=3D<module parameters> eth1=3D<module parameters>"


=09Donavan


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
