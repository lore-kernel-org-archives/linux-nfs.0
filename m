From: =?ISO-8859-1?Q?Andr=E9_Weidemann?= <Andre.Weidemann@web.de>
Subject: logging file access for a particular client
Date: Mon, 05 May 2003 14:52:19 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EB65E83.7070405@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp01.web.de ([217.72.192.180] helo=smtp.web.de)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19CfSH-0003c1-00
	for <nfs@lists.sourceforge.net>; Mon, 05 May 2003 05:52:30 -0700
Received: from p5090bfcf.dip.t-dialin.net ([80.144.191.207] helo=web.de)
	by smtp.web.de with asmtp (TLSv1:RC4-MD5:128)
	(WEB.DE 4.98 #218)
	id 19CfS9-00032A-00
	for nfs@lists.sourceforge.net; Mon, 05 May 2003 14:52:21 +0200
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

Hi,
I have a client running with its root FS mounted via NFS.
The client files are all located on the server but I don't need all 
installed files and libraries for the client. The client needs no more 
than 30 MB of files to start up and keep running. I would like to 
identify exactly those files and remove the others from the server.

What I want is a simple way of tracking the files that are being 
accessed by a particular client. Is there a way to do this?

Thanks a lot in advance,
  André.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
