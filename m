From: Kyle Rose <krose+linuxnfs@krose.org>
Subject: Re: Problem with NFS, Linux 2.6.2
Date: Wed, 04 Feb 2004 16:19:20 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87ad3ya6g7.fsf@nausicaa.krose.org>
References: <200402041933.52329.marcel.wiesweg@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoUQp-0005JT-Ba
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 13:19:35 -0800
Received: from dsl092-073-159.bos1.dsl.speakeasy.net ([66.92.73.159] helo=yupa.krose.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1AoUQm-0005Wz-DS
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 13:19:32 -0800
To: Marcel Wiesweg <marcel.wiesweg@gmx.de>
In-Reply-To: <200402041933.52329.marcel.wiesweg@gmx.de> (Marcel Wiesweg's
 message of "Wed, 4 Feb 2004 19:33:51 +0100")
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

Marcel Wiesweg <marcel.wiesweg@gmx.de> writes:

> after switching to 2.6 I noticed a strange bug which makes my NFS setup 
> unusable.
...
> Any suggestions?

Check your MTU on both ends.  I had the same problem, and it turned
out to be due to mismatched MTU's (1500 vs 1435).  Unknown to me why
this problem appeared with 2.6.

Cheers,
Kyle


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
