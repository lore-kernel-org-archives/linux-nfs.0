From: "Chimento, Douglas" <Douglas.Chimento@FMR.COM>
Subject: RE: TCP: Server unavailable
Date: Fri, 24 Oct 2003 17:04:44 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5C4853FD4EFB164A8F4FE5AFF13063219DA8FB@MSGBOSCLD2WIN.DMN1.FMR.COM>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AD9BZ-000354-00
	for <nfs@lists.sourceforge.net>; Fri, 24 Oct 2003 14:09:29 -0700
Received: from maillnx-us111.fmr.com ([192.223.198.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AD97N-0004dD-IT
	for nfs@lists.sourceforge.net; Fri, 24 Oct 2003 14:05:09 -0700
Received: from virmmk110nts.fmr.com (VIRMMK110NTS.fmr.com [172.25.107.117])
	by maillnx-us111.fmr.com (Switch-2.2.8/Switch-2.2.8) with SMTP id h9OL52X10884
	for <nfs@lists.sourceforge.net>; Fri, 24 Oct 2003 17:05:02 -0400
To: "'Matthew Galgoci'" <mgalgoci@redhat.com>
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

Thank you,
In fact that was the issue, I recompiled the kernel with TCP support and the
client was able to mount via tcp.
I wish to add the performance over TCP appears to be better than udp

Thanks

-----Original Message-----
From: Matthew Galgoci [mailto:mgalgoci@redhat.com] 
Sent: Friday, October 24, 2003 5:00 PM
To: Chimento, Douglas
Cc: 'nfs@lists.sourceforge.net'
Subject: Re: [NFS] TCP: Server unavailable


> 
> # rpcinfo -p
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     100024    1   udp  32768  status
>     100024    1   tcp  32768  status
>     100007    2   udp    819  ypbind
>     100007    1   udp    819  ypbind
>     100007    2   tcp    822  ypbind
>     100007    1   tcp    822  ypbind
>     391002    2   tcp  32769  sgi_fam
>     390113    1   tcp   7937
>     100011    1   udp    931  rquotad
>     100011    2   udp    931  rquotad
>     100011    1   tcp    934  rquotad
>     100011    2   tcp    934  rquotad
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs

The server is not advertising nfs v3 over tcp support. Perhaps the kernel
the server
is running does not support nfsv3 over tcp? I don't think any of the Red Hat
Linux 9
kernels include nfs v3 over tcp support.

-- 

Matthew Galgoci		"If you were a woman I'd kiss you right now."
System Administrator
Red Hat, Inc
919.754.3700 x44155


-------------------------------------------------------
This SF.net email is sponsored by: The SF.net Donation Program.
Do you like what SourceForge.net is doing for the Open
Source Community?  Make a contribution, and help us add new
features and functionality. Click here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
