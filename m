From: Donavan Pantke <avatar@dcr.net>
Subject: Re: huge number of intr/s on large nfs server
Date: Wed, 16 Oct 2002 18:51:07 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200210161851.07174.avatar@dcr.net>
References: <CFEAJJEGMGECBCJFLGDBKELFCFAA.enorwood@effrem.com>
Reply-To: avatar@dcr.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.dcr.net ([216.7.64.2] helo=andrew.dcr.net)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 181x0I-0004oV-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Oct 2002 15:51:02 -0700
To: "Eff Norwood" <enorwood@effrem.com>,
   "Andrew Theurer" <habanero@us.ibm.com>, <nfs@lists.sourceforge.net>
In-Reply-To: <CFEAJJEGMGECBCJFLGDBKELFCFAA.enorwood@effrem.com>
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

On Wednesday 16 October 2002 16:06, Eff Norwood wrote:

> > This can be any module, binary only or not, for kernprof.  It is
> > most likely
> > your module for the GigE card. Can you check, and if possible,
> > build it into
> > the kernel?
>
> I can't build the gigabit into the kernel because I need to pass the mo=
dule
> parameters. The rest I can and will build into the kernel.
>


=09Umm... just a small interjection, but can't you just pass the paramete=
rs=20
through LILO or GRUB? I remember doing that for several Dual-NIC firewall=
s.

=09Donavan Pantke


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
