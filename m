From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: NFS problem on Debian Woody
Date: Mon, 14 Apr 2003 18:48:25 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200304141848.26046.bernd-schubert@web.de>
References: <000d01c3026f$227cde60$00000a0a@andromeda>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="windows-1252"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19578C-0003Zz-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Apr 2003 09:48:32 -0700
To: "Charis Charalambous" <charalambous@softnet.tuc.gr>
In-Reply-To: <000d01c3026f$227cde60$00000a0a@andromeda>
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

On Monday 14 April 2003 12:16, Charis Charalambous wrote:
> When i try to mount a dir with NFS with 2 PCs running Woody r3.0 i get (on
> the client of course): RPC:Port mapper failure-RPC:Unable to send
>
> Both PCs run:
> nfs-comon 1.0-2
> nfs-kernel-server 1.0-2
> nfs-user-server 2.2beta47-12
> kernel 2.2.20-idepci
> Debian Woody r3.0
>
> In the server i use the scripts:
> /etc/init.d/nfs-common start
> /etc/init.d/nfs-kernel-server start
> /etc/init.d/nfs-user-server start

Do you have a kernel that has nfsd support ?

Why do you start unfsd ?

>
> and on the client:
> /etc/init.d/nfs-common start

What's about starting "/etc/init.d/portmap"  on the client ?

Bernd



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
