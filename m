From: "Felipe Alfaro Solana" <felipe_alfaro@linuxmail.org>
Subject: Bug: 2.5.47 NFS reports giant filename in readdir
Date: Mon, 18 Nov 2002 20:21:19 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021118192119.12935.qmail@linuxmail.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 205-158-62-68.outblaze.com ([205.158.62.68] helo=spf0.us4.outblaze.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18DrSZ-0003hh-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Nov 2002 11:21:27 -0800
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

Hello,

I'm currently testing kernel 2.5.47 on a RedHat 8.0 server machine, serving files through NFS among many other things. Since I'm using 2.5.47, there are several directories I'm unable to browse using NFS from my laptop running 2.4.20-rc1.

This is "/etc/exports" on the 2.5.47 machine:

/                        192.168.0.0/255.255.255.0(rw,async,no_root_squash)
/data                    192.168.0.0/255.255.255.0(rw,async,no_root_squash)

And these are the commands I use on the 2.4.20-rc1 machine to mount and browse the directory using NFS:

# mount glass:/data /net/glass/data
# cd /net/glass/data/Jpgs/Jpgs11
# ls

The last command produces an empty listing, even when the directory contains 16694 files on it. When I do a "dmesg" on my 2.4.20-rc1 machine, I see the following errors:

NFS: giant filename in readdir (len 14000000)!
NFS: giant filename in readdir (len 40404000)!
NFS: giant filename in readdir (len f000000)!

I haven't been able to find any debugging information or message on the server side. dmesg reports nothing, and all log files contain no clue about this error.

I think this must be a bug on 2.5.47 as this works great when using the latest RedHat 8.0 kernel on the server side.

I can't supply more information as I don't know exactly where to start looking.
Please, do not hesitate to contact me for further information or assistance.

Thank you very much!

Sincerely,

   Felipe Alfaro Solana

-- 
______________________________________________
http://www.linuxmail.org/
Now with POP3/IMAP access for only US$19.95/yr

Powered by Outblaze


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
