From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS rpc.lockd
Date: Tue, 18 May 2004 17:29:50 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40AA804E.2020008@RedHat.com>
References: <SEA2-F32biHKwf6Ihkg0000e266@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BQCA7-0000xm-RB
	for nfs@lists.sourceforge.net; Tue, 18 May 2004 14:30:11 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BQCA7-0005kZ-4W
	for nfs@lists.sourceforge.net; Tue, 18 May 2004 14:30:11 -0700
To: James Bond <jamesbond_422@hotmail.com>
In-Reply-To: <SEA2-F32biHKwf6Ihkg0000e266@hotmail.com>
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

James Bond wrote:

> Can anyone lete me know if i need to start this services or RHEL3 
> kernel starts this service by itself.

Yes... you need to start lockd and RHEL3 will start it automatically...

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
