From: Robert Myers <rmyers1400@comcast.net>
Subject: Re: nfs connection refuse
Date: Sun, 24 Aug 2003 11:23:45 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F48D881.1090804@comcast.net>
References: <Law11-OE20biNh0Ow0w0002c234@hotmail.com>
Reply-To: rmyers@rustuck.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [204.127.202.55] (helo=sccrmhc11.comcast.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19qwiw-0005Tb-00
	for <nfs@lists.sourceforge.net>; Sun, 24 Aug 2003 08:24:10 -0700
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

> I set up nfs on redhat linux 9. I created dir and mount locally, It’s 
> work. But when I try to mount remotely from another redhat linux 9, I 
> got error message RPC: connection refuse. I can ping both ways. I also 
> replace host name with the IP address to eliminate DNS problem. But I 
> still get the same error message.
>
> Please suggest what else I need to do to resolve this error message.
>
You probably need to punch some holes in your firewalls. In fact you 
will pretty much need to allow the two machines to exchange information 
on any port they want, since the RedHat portmapper can put NFS 
communication on nearly any port. You will probably want to read about 
securing NFS in the RedHat Linux Security Guide.

RM





-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
