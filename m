From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] -o intr  mount option prevents core dumps on 2.4
 kernel
Date: Fri, 14 Jan 2005 14:52:35 -0500
Message-ID: <41E82303.2070804@RedHat.com>
References: <41DD8403.7030601@RedHat.com>	 <1105118040.10979.70.camel@lade.trondhjem.org>	 <41E42AD7.3030303@RedHat.com> <1105474246.11430.1.camel@lade.trondhjem.org>	 <41E43DE1.5080703@RedHat.com>	 <1105480745.11430.56.camel@lade.trondhjem.org> <41E569E3.20206@RedHat.com>	 <1105554342.23943.1.camel@lade.trondhjem.org> <41E5767F.40204@RedHat.com>	 <1105576681.14443.100.camel@lade.trondhjem.org>	 <41E67F38.6060203@RedHat.com>  <41E6EA19.4030806@RedHat.com> <1105671434.20314.3.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpXV6-0007QY-FX
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 11:52:52 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CpXV6-0001rs-0v
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 11:52:52 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1105671434.20314.3.camel@lade.trondhjem.org>
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



Trond Myklebust wrote:

>to den 13.01.2005 Klokka 16:37 (-0500) skreiv Steve Dickson:
>
>  
>
>>after further review.... it seems the reason your patch works on a 
>>2.4.28 kernel, is
>>because signalled() never returns true, even when the process is sent 
>>the SIGSEGV signal. Why signalled() never returns true, I don't know.... 
>>but the
>>reason your patch did not work on a RHEL3 kernel is because signalled() 
>>does
>>return true and calls to recalc_sigpending() do not reset that pending 
>>signal....
>>which seems to be a bug in the NTPL-related code.... code that is not in the
>>2.4.28 kernel....
>>    
>>
>
>recalc_sigpending() failing to honour the sigmask sounds like a pretty major bug! 
>  
>
Well it turns it was a bug in the kernel signaling code which was causing
this issue.... which means there are no changes needed to the NFS code,
which is always a good thing... :)

See bz 132162 if interested....

steved.





-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
