From: "Gareth" <gareth@bim7.com>
Subject: Re: Re: Premission denied
Date: Thu, 30 Oct 2003 11:58:45 -0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <18043.62.49.205.2.1067515125.squirrel@squirrelmail.bim7.com>
References: <10334.62.49.205.2.1067421598.squirrel@squirrelmail.bim7.com><20031029215815.GO29526@perlsupport.com>
    <16288.41100.10180.44099@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AFBRy-0006WD-00
	for <nfs@lists.sourceforge.net>; Thu, 30 Oct 2003 03:58:50 -0800
Received: from bim7dsl.plus.com ([81.174.146.28] helo=mailgate.bim7.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AFBRy-0000Cr-C8
	for nfs@lists.sourceforge.net; Thu, 30 Oct 2003 03:58:50 -0800
In-Reply-To: <16288.41100.10180.44099@notabene.cse.unsw.edu.au>
To: "Neil Brown" <neilb@cse.unsw.edu.au>
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

>> > Someone at work suggested its a reverse DNS problem... but running
>> > nslookup hostname returns my IP address, and vice versa.
>>
>> The log says there was a reverse DNS problem.  It says it clearly,
>> right there in the log.  Are you suggesting that it's lying?
>
> Funny, but I don't see the letters "DNS" in the log at all :-)
>
> What does /etc/nsswitch.conf say about hosts? Does "files" come before
> "dns"?

files is before dns...

the only entries in my /etc/hosts are...

# Do not remove the following line, or various programs
# that require network functionality will fail.
127.0.0.1               localhost.localdomain localhost
192.168.17.4            paris.bim paris

does that look okay?

Gareth


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
