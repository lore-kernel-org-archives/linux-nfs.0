From: Alejandra <alejamilis@gmail.com>
Subject: help with nfs
Date: Fri, 22 Apr 2005 09:55:37 -0300
Message-ID: <3dd7287a05042205554e966492@mail.gmail.com>
Reply-To: Alejandra <alejamilis@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOxhB-00050i-PU
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 05:55:45 -0700
Received: from zproxy.gmail.com ([64.233.162.195])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DOxhA-0003Dy-1p
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 05:55:45 -0700
Received: by zproxy.gmail.com with SMTP id 16so1190752nzp
        for <nfs@lists.sourceforge.net>; Fri, 22 Apr 2005 05:55:37 -0700 (PDT)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

I'm trying to share some directories using nfs, and although I've
modified the hosts.allow,hosts.deny and export files as the tutorial
says, it doesn't work. I'm working in a simple workgroup of four
computers  - three of them have both w2k and Fedora Core 3.
Nfs-utils : version 1.0.6-39
Kernel: 2.6.9
=20
This is my /etc/export:

#Archivos a compartir

/exportaciones=09192.168.1.21(rw) 192.168.1.15(rw) 192.168.1.48(rw)

This is /etc/hosts.allow:

portmap: 192.168.1.48 , 192.168.1.15 , 192.168.1.48
lockd: 192.168.1.48 , 192.168.1.15 , 192.168.1.48
mountd: 192.168.1.48 , 192.168.1.15 , 192.168.1.48
rquotad: 192.168.1.48 , 192.168.1.15 , 192.168.1.48
statd: 192.168.1.48 , 192.168.1.15 , 192.168.1.48

This is /etc/hosts.deny:

portmap:ALL
lockd:ALL
mountd:ALL
rquotad:ALL
statd:ALL

The problem is that, when the client tries to mount /export, the
following error apprears:
<server not mounted>

I've strictly followed the instructions in the tutorial, but I cannot
solve this problem, I hope you can help me.

Thank you in advance

Alejandra Jamilis


-------------------------------------------------------
SF.Net email is sponsored by: Tell us your software development plans!
Take this survey and enter to win a one-year sub to SourceForge.net
Plus IDC's 2005 look-ahead and a copy of this survey
Click here to start!  http://www.idcswdc.com/cgi-bin/survey?id=105hix
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
