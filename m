From: Kumaran Rajaram <kums@HPCL.CSE.MsState.Edu>
Subject: Re: Application locked when network crash
Date: Tue, 17 Jun 2003 10:00:40 -0500 (CDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.44.0306170955190.26854-100000@aurora.cs.msstate.edu>
References: <01cf01c334df$952558f0$0202a8c0@jackyhome>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from aurora.cs.msstate.edu
	([130.18.209.4] helo=HPCL.CSE.MsState.Edu ident=daemon)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SHx5-00053h-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 08:00:51 -0700
To: Jacky Lam <faichai0@yahoo.com>
In-Reply-To: <01cf01c334df$952558f0$0202a8c0@jackyhome>
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


Jacky,

  The problem is bacause you have hard-mounted the file system which
causes infinite loop of RPC retransmission and timeouts. Try to do
hard-mount with the "intr" option enabling user to interrupt/break the
retransmission loop. Or else, try soft-mounting with "retrans/timeo"
option.

-Kums

-- Kumaran Rajaram, Mississippi State University --
kums@hpcl.cs.msstate.edu    <http://www.cs.msstate.edu/~kums/>


On Tue, 17 Jun 2003, Jacky Lam wrote:

> Dear all,
>
>     I am not very familiar with nfs. Currently, I connect a client with an
> nfs server. When the client is reading/writing from/to the server, the
> network is crashed(I repeat the problem by removing the network cable).
> Then, the client is hanged. How can the client get out from the hang in
> customed timeout(or at least in short period of time)? Thanks very much.
>
>     (Please cc to my email because I haven't subscribed the list yet.
> Thanks)
>
> Yours,
> Jacky
>
>
>
> -------------------------------------------------------
> This SF.Net email is sponsored by: INetU
> Attention Web Developers & Consultants: Become An INetU Hosting Partner.
> Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
> INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
