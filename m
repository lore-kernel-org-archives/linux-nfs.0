From: Steve Dickson <SteveD@redhat.com>
Subject: Re: stat'ing >4TB NFS filesystems
Date: Fri, 16 Jul 2004 06:21:51 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40F7AC3F.5050800@RedHat.com>
References: <20040715192125.GZ22659@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BlPqp-00050n-0U
	for nfs@lists.sourceforge.net; Fri, 16 Jul 2004 03:21:59 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BlPqo-0006tA-L7
	for nfs@lists.sourceforge.net; Fri, 16 Jul 2004 03:21:58 -0700
To: Garrick Staples <garrick@usc.edu>
In-Reply-To: <20040715192125.GZ22659@polop.usc.edu>
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



Garrick Staples wrote:

>   I have some RHE3 machines (2.4.21) here that can't properly stat a 5GB filesystem,
>but some RH7.2 machines with (vanilla 2.4.26) can stat it fine.  I searched for
>the lkml looking for NFS patches since 2.4.21 but couldn't find anything.
>Can anyone here point me to the right patch?
>
>  
>
There are a couple patches in
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=121475
one of which made it into U3....

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
