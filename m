From: Emanuel Quass <emanuel.quass@temic.com>
Subject: Re: IRIX NFS server and Linux NFS client
Date: Thu, 11 Apr 2002 14:10:06 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200204111210.g3BCA6x04781@in-cadcae4.ing.temic.de>
References: <Pine.LNX.4.30.0204110928530.28565-100000@elin.scali.no>
Reply-To: emanuel.quass@temic.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from letterman.noris.net ([62.128.1.26])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vdPE-0001Eo-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Apr 2002 05:10:24 -0700
To: Steffen Persvold <sp@scali.com>, <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.30.0204110928530.28565-100000@elin.scali.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi,

I'm running as Client Linux 2.4.4 (kernel patched by SuSE) against 
AIX-Servers(aix-4.3.3) / IRIX-Servers (6.5.9 and 6.5.11) / 
Linux-Servers(2.4.9 and 2.2.17 both with NFS-Patches) and I can connect from 
my Client to any Server with Version 3 (UDP of course).

I'm sorry that I can't give you a hint apart from upgrading nfs-utils to 
0.3.3.

MfG
	Emanuel


Am Donnerstag, 11. April 2002 09:34 schrieb Steffen Persvold:
> Hi all,
>
> Is there any reason why my Linux NFS client (kernel 2.4.18
> nfs-utils-0.3.1-13.7.2.1 from RedHat 7.2) is not able to mount a directory
> exported from an IRIX server in NFSv3 (not sure which version of IRIX
> yet, if this is important I will find out). NFSv2 works fine, but if I
> try to force NFSv3 I get "Connection refused".
>
> I'll appreciate any help.
>
> Regards,

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
