From: Brian Tinsley <btinsley@emageon.com>
Subject: Unexpected error
Date: Fri, 15 Aug 2003 00:40:43 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F3C725B.8070300@emageon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from imf24aec.mail.bellsouth.net ([205.152.59.72])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19nXLH-0003pY-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Aug 2003 22:41:39 -0700
Received: from emageon.com ([68.17.150.106]) by imf24aec.mail.bellsouth.net
          (InterMail vM.5.01.05.27 201-253-122-126-127-20021220) with ESMTP
          id <20030815054133.RFJU19510.imf24aec.mail.bellsouth.net@emageon.com>
          for <nfs@lists.sourceforge.net>; Fri, 15 Aug 2003 01:41:33 -0400
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

Hi!

Can anyone elaborate on what may have caused the following error:

Aug 14 22:09:09 clarc02 kernel: nfsd-fh: found a name that I didn't 
expect: files/19
Aug 14 22:09:40 clarc02 last message repeated 2314 times
Aug 14 22:15:56 clarc02 last message repeated 1088 times
Aug 14 22:17:10 clarc02 last message repeated 138 times
Aug 14 22:19:03 clarc02 last message repeated 138 times
Aug 14 22:20:53 clarc02 last message repeated 2 times
Aug 14 22:21:30 clarc02 last message repeated 73 times

The underlying filesystem is reiserfs and there was a high volume of 
writing taking place (or trying to) during this time. None of the writes 
succeeded as the client was returned EEXIST errors. However, the writes 
were reissued in full shortly after the last occurence and everything 
automagically started working properly again.

I'm trying to decipher the source code, but it's a bit out of my area of 
expertise ;-)

Thanks!




-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
