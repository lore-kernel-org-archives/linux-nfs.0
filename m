From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: nfs connection refuse
Date: Mon, 25 Aug 2003 07:07:00 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F49EDD4.2030603@RedHat.com>
References: <Law11-OE20biNh0Ow0w0002c234@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19rFCM-0004pq-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Aug 2003 04:07:46 -0700
To: will supat <willsupat@hotmail.com>
In-Reply-To: <Law11-OE20biNh0Ow0w0002c234@hotmail.com>
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

will supat wrote:

> I set up nfs on redhat linux 9. I created dir and mount locally, It=92s=
=20
> work. But when I try to mount remotely from another redhat linux 9, I=20
> got error message RPC: connection refuse. I can ping both ways. I also=20
> replace host name with the IP address to eliminate DNS problem. But I=20
> still get the same error message.
>
> Please suggest what else I need to do to resolve this error message.
>
It sounds like the filesystems may not be exported. Use=20
redhat-config-nfs to
export the filesystem.

SteveD




-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
