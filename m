From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Stale NFS file handle
Date: Wed, 23 Mar 2005 08:12:44 -0500
Message-ID: <42416B4C.2010505@RedHat.com>
References: <20050322210033.BEAC.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DE5Wp-0001K4-RA
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 05:04:07 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DE5Wo-0004Fo-AT
	for nfs@lists.sourceforge.net; Wed, 23 Mar 2005 05:04:07 -0800
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20050322210033.BEAC.BRANDEN@terra.com.br>
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

Filipe Brandenburger wrote:
> I have a problem where I'm getting "Stale NFS file handle" errors when a
> file is updated. I can easily reproduce the problem if I run a sequence
> of commands in two different hosts.
> 
> My environment is:
> 
> 1) Server: Netapp FAS940
> 2) Client 1: Linux RedHat 9 with kernel 2.4.21-4.ELsmp (kernel of RHAS3)
> 3) Client 2: exactly the same as client 1.
Sometime back there was an Netapp issue that was causing
ESTALES with mostly 2.4 kernels... I upgraded the OS on
our toater and the problem when away....

steved.


-------------------------------------------------------
This SF.net email is sponsored by: 2005 Windows Mobile Application Contest
Submit applications for Windows Mobile(tm)-based Pocket PCs or Smartphones
for the chance to win $25,000 and application distribution. Enter today at
http://ads.osdn.com/?ad_id=6882&alloc_id=15148&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
