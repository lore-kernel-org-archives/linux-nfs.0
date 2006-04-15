From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: No UDP NFS over bridges in Linux 2.6.16.x?
Date: Fri, 14 Apr 2006 22:17:59 -0700
Message-ID: <44408207.1070404@osdl.org>
References: <20060414235008.66335.qmail@web52913.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: bridge@osdl.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FUdAb-0008O8-EB
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 22:18:05 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1FUdAa-0007ax-5X
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 22:18:05 -0700
To: Chris Rankin <rankincj@yahoo.com>
In-Reply-To: <20060414235008.66335.qmail@web52913.mail.yahoo.com>
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

Then get a packet trace of a failing session with tcpdump. You may need 
to get two, one
one the client and one on the server to be able to see which packet 
isn't getting past the
bridge.

There are tools to santize tcpdump files if you are paranoid about IP 
adresses, etc.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
