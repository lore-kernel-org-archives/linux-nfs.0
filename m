From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Unable to handle kernel NULL pointer dereference at virtual address 00000000
Date: Thu, 3 Jul 2003 11:36:23 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16131.34967.583276.739735@gargle.gargle.HOWL>
References: <A6D9D7495456414BA08DB655C2AC6712013667D4@bsebe001.americas.nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Xt1U-0005wB-00
	for <nfs@lists.sourceforge.net>; Wed, 02 Jul 2003 18:36:32 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <Nikolaos.Michalakis@nokia.com>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Thu, 3 Jul 2003 11:36:23 +1000
To: <Nikolaos.Michalakis@nokia.com>
In-Reply-To: message from Nikolaos.Michalakis@nokia.com on Wednesday July 2
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

On Wednesday July 2, Nikolaos.Michalakis@nokia.com wrote:
> Hi,
> 
> I got the latest nfs-utils from the sourceforge website and I am trying to get a working nfs-kernel-server on an ARM processor running intimate linux (Debian clone). I compiled the source code, installed the binaries, setup 
> /etc/exports but when I try to access the server the kernel oops.
> 
> Here is the scenario:
> 1. I can mount the exported directory successfully.
> 2. When I try to 'ls' the contents of the directory I get on the client:
> 	ls: <filename1>: Input/Output error
> 	ls: <filename2>: Input/Output error
> 	...
> 	ls: <filenameN>: Input/Output error
> 	(the filenames are the exact ones on the server)

Very odd...

> Backtrace:
> Function entered at [<c002442c>] from [<c001ba48>]
> Function entered at [<c001ba00>] from [<c001bccc>]
>  r8 = C037CA00  r7 = C24CC204  r6 = C1A81000  r5 = C24CC214
>  r4 = C037CCB4
> Function entered at [<c4a8e7a4>] from [<c4a8ee04>]
> Function entered at [<c4a8eb7c>] from [<c4a96bb8>]
> Function entered at [<c4a96af4>] from [<c4a8c6ac>]
> Function entered at [<c4a8c5d0>] from [<c4a72ed8>]
>  r8 = C4A9EB94  r7 = 00000001  r6 = C25FC014  r5 = C24F0E00
>  r4 = C24F0F38
> Function entered at [<c4a72bc0>] from [<c4a8c408>]
> Function entered at [<c4a8c1c4>] from [<c001ac5c>]
> Code: e5903004 e5802004 e5810008 e5823004 (e5832000)
> 

You need to some how convert these addresses, inside "[<..>]" to
syumbolic addresses in the kernel.
You can do it with gdb:

  gdb vmlinux
  disassemble 0xc002442c

but that can be a bit laborious.  There is a program called "ksymoops"
which does it for you, if you can find an 'arm' version.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
