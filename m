From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [USN-36-1] NFS statd vulnerability
Date: Wed, 01 Dec 2004 20:32:35 -0500
Message-ID: <1101951155.32266.47.camel@lade.trondhjem.org>
References: <20041201143603.GA15315@box79162.elkhouse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CZfpz-00019Y-RB
	for nfs@lists.sourceforge.net; Wed, 01 Dec 2004 17:32:51 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CZfpx-0000wI-6D
	for nfs@lists.sourceforge.net; Wed, 01 Dec 2004 17:32:51 -0800
To: Martin Pitt <martin.pitt@canonical.com>
In-Reply-To: <20041201143603.GA15315@box79162.elkhouse.de>
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

on den 01.12.2004 Klokka 15:36 (+0100) skreiv Martin Pitt:

> SGI discovered a remote Denial of Service vulnerability in the NFS
> statd server. statd did not ignore the "SIGPIPE" signal which caused
> it to shutdown if a misconfigured or malicious peer terminated the TCP
> connection prematurely.

WTF wasn't this first fixed in the actual upstream nfs-utils package?
WTF are we only hearing of this now via bugtraq?

Grrr.....

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
