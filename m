From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] -o intr  mount option prevents core dumps on 2.4
 kernel
Date: Thu, 13 Jan 2005 16:37:29 -0500
Message-ID: <41E6EA19.4030806@RedHat.com>
References: <41DD8403.7030601@RedHat.com>	 <1105118040.10979.70.camel@lade.trondhjem.org>	 <41E42AD7.3030303@RedHat.com> <1105474246.11430.1.camel@lade.trondhjem.org>	 <41E43DE1.5080703@RedHat.com>	 <1105480745.11430.56.camel@lade.trondhjem.org> <41E569E3.20206@RedHat.com>	 <1105554342.23943.1.camel@lade.trondhjem.org> <41E5767F.40204@RedHat.com> <1105576681.14443.100.camel@lade.trondhjem.org> <41E67F38.6060203@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpCf5-0006SD-Me
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 13:37:47 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CpCf4-0007ZH-LC
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 13:37:47 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j0DLbe02019704
	for <nfs@lists.sourceforge.net>; Thu, 13 Jan 2005 16:37:45 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j0DLbTr03235
	for <nfs@lists.sourceforge.net>; Thu, 13 Jan 2005 16:37:29 -0500
Received: from [172.16.80.110] (IDENT:U2FsdGVkX18uJ2H0cbFsURsXlmIOsIUxDyvs8QvrVaw@dickson.boston.redhat.com [172.16.80.110])
	by lacrosse.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j0DLbTa03224
	for <nfs@lists.sourceforge.net>; Thu, 13 Jan 2005 16:37:29 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <41E67F38.6060203@RedHat.com>
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



Steve Dickson wrote:

>
>> As for myself, I'm getting full coredumps when I apply the 2 line patch
>> I sent you. The appended testcase works every time:
>>  
>>
> hmm.... something is amiss.... because I'm definitely not see this.... 
> but I'll keep digging...

after further review.... it seems the reason your patch works on a 
2.4.28 kernel, is
because signalled() never returns true, even when the process is sent 
the SIGSEGV signal. Why signalled() never returns true, I don't know.... 
but the
reason your patch did not work on a RHEL3 kernel is because signalled() 
does
return true and calls to recalc_sigpending() do not reset that pending 
signal....
which seems to be a bug in the NTPL-related code.... code that is not in the
2.4.28 kernel....

steved.




-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
