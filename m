From: Ian Kent <raven@themaw.net>
Subject: Re: RPC Time Out
Date: Thu, 4 Dec 2003 14:15:44 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0312041408210.12549-100000@wombat.indigo.net.au>
References: <Pine.LNX.4.33.0312040951120.7055-100000@wombat.indigo.net.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARmkA-0000bM-Oe
	for nfs@lists.sourceforge.net; Wed, 03 Dec 2003 22:13:42 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARmkA-00034H-3R
	for nfs@lists.sourceforge.net; Wed, 03 Dec 2003 22:13:42 -0800
To: "Weber, Eugene F (Gene)" <efw@agere.com>
In-Reply-To: <Pine.LNX.4.33.0312040951120.7055-100000@wombat.indigo.net.au>
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

On Thu, 4 Dec 2003, Ian Kent wrote:

> On Mon, 1 Dec 2003, Weber, Eugene F (Gene) wrote:
>
> >
> > SETTING UP THE CLIENT
> > ====================
> > rpcinfo -p on the Debian laptop gave an rpc error. I saw
> > that none of the services existed anywhere on the
> > machine. I installed package "portmap_5-2_i386.deb"
> > and package "nfs-common_1.0-2_i386.deb". After the
> > successful installs, portmap, statd and lockd all existed
> > under /sbin. The installation also said it started each of
> > the services. rpcinfo -p now showed:
> >
> > program vers proto port
> > 100000 2 tcp 111 portmapper
> > 100000 2 udp 111 portmapper
> > 100024 1 udp 1024 status
> > 100024 1 tcp 1024 status
> >
> > I though perhaps lockd was not started, but executing it
> > and then checking rpcinfo -p gives the same result??
> > The shown services now seemed to be launched at boot
> > up.
> >
> > rpcinfo -p 192.168.2.57 from the client gives the same
> > result as doing rpcinfo -p on the server. Likewise doing
> > rpcinfo -p 192.168.2.51 from the server gives the same
> > result as doing rpcinfo -p on the client.
>
> But what does a showmount -e show on the server and what does
> a showmount -e 192.168.2.57 give on the client.
>
>

All I'm trying to say is "can you see the servers' export list".

ie. showmount -e <server ip>

on the client

You can check your exports list on the server using exportfs but if you
use showmount -e it will fail if the rpc service is not registered.

Just a check.

If your export lists are not what you expect then re-export them with

exportfs -ra

should fix it up.

Worth a try!

-- 

   ,-._|\    Ian Kent
  /      \   Perth, Western Australia
  *_.--._/   E-mail: raven@themaw.net
        v    Web: http://themaw.net/



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
