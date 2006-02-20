From: Daniel Bramkamp <bramkamp@team-datentechnik.de>
Subject: Re: Permission denied
Date: Mon, 20 Feb 2006 13:16:37 +0100
Message-ID: <20060220131637.iqam5s8yb4o8co44@linux-smb.molly>
References: <20060207123448.pqv165xvwosgk0g8@linux-smb.molly>
	<20060220112535.GA10567@janus>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-15;
	format="flowed"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FB9yB-0004uD-2F
	for nfs@lists.sourceforge.net; Mon, 20 Feb 2006 04:16:47 -0800
Received: from natnoddy.rzone.de ([81.169.145.166])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FB9y8-0004yf-Ue
	for nfs@lists.sourceforge.net; Mon, 20 Feb 2006 04:16:47 -0800
Received: from linux-smb.molly ([85.8.92.16])
	by post.webmailer.de (8.13.1/8.13.1) with ESMTP id k1KCGeoq011236
	for <nfs@lists.sourceforge.net>; Mon, 20 Feb 2006 13:16:40 +0100 (MET)
Received: from localhost (localhost [127.0.0.1])
	by linux-smb.molly (Postfix) with ESMTP id 180CF45A32
	for <nfs@lists.sourceforge.net>; Mon, 20 Feb 2006 13:16:40 +0100 (CET)
Received: from linux-smb.molly ([127.0.0.1])
 by localhost (linux-smb.molly [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 05306-06 for <nfs@lists.sourceforge.net>;
 Mon, 20 Feb 2006 13:16:37 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <20060220112535.GA10567@janus>
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

Quoting Frank van Maarseveen <frankvm@frankvm.com>:

> On Tue, Feb 07, 2006 at 12:34:48PM +0100, Daniel Bramkamp wrote:
>> Hi list,
>>
>> I am experiencing some issues with a NFS server running on Linux Kernel
>> 2.4.26 with nfs-utils-1.0.6 installed. Basically it works great,
>> however, sometimes access to files and directories stored on the server
>> is denied for a certain user account. I am not sure if it affects other
>> users as well - only heard complaints from that particular user so far.
>
> A bit late but.. is that user a member of more than 16 groups?

Hi,

yesterday I reinstalled the server. The server is now running Gentoo 
instead of Slackware. The installed software is up to date now. Kernel 
is 2.6.14, nfs-utils is still 1.0.6, it seems 1.0.8 is currently a 
realease candidate. Half an hour ago I got a call from the user - the 
problem still exists. The user is a member of 13 groups. I really hoped 
the update would solve the problem since I have no idea how to fix this.

-- 
Daniel Bramkamp

team! datentechnik GmbH & Co.KG
Werner von Siemens Stra=DFe 12a
49124 Georgsmarienh=FCtte
Tel.: 05401-8226-0
Fax : 05401-8226-20
eMail: bramkamp@team-datentechnik.de


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
