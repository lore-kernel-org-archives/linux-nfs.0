From: Steve Dickson <SteveD@redhat.com>
Subject: Re: lockd recovery failure
Date: Wed, 08 Dec 2004 11:35:48 -0500
Message-ID: <41B72D64.80404@RedHat.com>
References: <20041208151749.82833.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cc4nF-0003FG-Nu
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 08:35:57 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cc4nD-0006s6-CC
	for nfs@lists.sourceforge.net; Wed, 08 Dec 2004 08:35:57 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20041208151749.82833.qmail@web51603.mail.yahoo.com>
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



mehta kiran wrote:

>Hi , 
>    I have RHEL 4.0 beta2 installed on my machines.
>    NFS server run on these machines.
>    NFS client runs on machine with sles9 sp1 beta3 
>    installed.
>  
>
The lock recovery in the 2.6 does work.... I've recently sent out 
server, client and statd
patches that should take care of the problem.... These patches will in 
the RHEL4 RC
release.

steved.



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
