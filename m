From: Jean-Denis Girard <jd-girard@esoft.pf>
Subject: 2.6.0-test1 ltsp server nfs problem
Date: Tue, 22 Jul 2003 07:40:47 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F1D22BF.1000707@esoft.pf>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ca03f80c.dialup.mana.pf ([202.3.248.12] helo=shuttle.esoft.pf)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19f19Z-0000SS-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Jul 2003 10:42:21 -0700
Received: from shuttle.esoft.pf (localhost.localdomain [127.0.0.1])
	by shuttle.esoft.pf (Postfix) with SMTP id 4E4CE9C546
	for <nfs@lists.sourceforge.net>; Tue, 22 Jul 2003 07:40:48 -0400 (EDT)
Received: from esoft.pf (localhost.localdomain [127.0.0.1])
	by shuttle.esoft.pf (Postfix) with ESMTP id D840F9C545
	for <nfs@lists.sourceforge.net>; Tue, 22 Jul 2003 07:40:47 -0400 (EDT)
To: nfs@lists.sourceforge.net
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

Hi,

We are running our office in a LTSP environment.

I installed 2.6.0-test1 on the server only, and it seems to work fine
(I'm sending this mail from this server), but my LTSP thin clients can
no longer mount their root partition. I get:

...
Mounting root filesystem: ... from: ...
Doing the pivot_root
nfs: nfs server ... not responding, still trying
nfs: task 83 can't get a request slot

And then nothing more...

On the server side /proc/net/rpc/*/content gives (client above is vpn1)
#class IP domain
nfsd 192.168.10.21 stb1.esoft.pf
nfsd 192.168.10.22 stb2.esoft.pf
nfsd 192.168.10.13 mahana.esoft.pf
nfsd 192.168.10.127 vpn1.esoft.pf
#path domain(flags)
/opt/ltsp/i386  mahana.esoft.pf(ro,no_root_squash,sync,wdelay)
/opt/ltsp/i386  stb2.esoft.pf(ro,no_root_squash,sync,wdelay)
/opt/ltsp/i386  vpn1.esoft.pf(ro,no_root_squash,sync,wdelay)
/opt/ltsp/i386  stb1.esoft.pf(ro,no_root_squash,sync,wdelay)
#domain fsidtype fsid [path]
stb1.esoft.pf 0 0x01000300 /opt/ltsp/i386
vpn1.esoft.pf 0 0x01000300 /opt/ltsp/i386
stb2.esoft.pf 0 0x01000300 /opt/ltsp/i386
mahana.esoft.pf 0 0x01000300 /opt/ltsp/i386

I can mount the same nfs share from another system (non LTSP) without
trouble. Nothing has changed on the client side which is straight
LTSP-3.0 (kernel 2.4.19-ltsp-1).

Server basically is a Mandrake-9.1 system, with nfs-utils-1.05
(recompiled from sources from nfs.sf.net).

What other details should I send ?

Thanks for any help.



-- 
Jean-Denis Girard

====================================================
Essential Software - Ingénierie Informatique
Solutions Linux & Open Source en Polynésie française
----------------------------------------------------
http://www.esoft.pf/
Tél: (689) 54 12 95
====================================================







-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
