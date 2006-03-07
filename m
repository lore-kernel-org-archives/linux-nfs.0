From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS possible race condition, nfs_unlink vs. d_lookup
Date: Tue, 07 Mar 2006 07:36:16 -0500
Message-ID: <440D7E40.9000401@RedHat.com>
References: <Pine.LNX.4.62.0603030955060.11612@snowball.fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FGbQP-000052-Gq
	for nfs@lists.sourceforge.net; Tue, 07 Mar 2006 04:36:25 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FGbQO-0004j6-A4
	for nfs@lists.sourceforge.net; Tue, 07 Mar 2006 04:36:25 -0800
To: Steven Timm <timm@fnal.gov>
In-Reply-To: <Pine.LNX.4.62.0603030955060.11612@snowball.fnal.gov>
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

Sorry for the delayed response...

Steven Timm wrote:
> My question.. is the 2.4.21-37 kernel as distributed by Red Hat also
> vulnerable to this race condition? 
Not that I'm aware of...

steved.



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
