From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: NFS3 in RHEL3
Date: Fri, 14 Apr 2006 18:12:22 -0400
Message-ID: <44401E46.10006@citi.umich.edu>
References: <443F37FA.2060402@oracle.com> <4440121F.5020704@totalflood.com>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FUWWf-0005Cx-Q4
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 15:12:25 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FUWWe-00024l-BC
	for nfs@lists.sourceforge.net; Fri, 14 Apr 2006 15:12:25 -0700
To: Stephen Carville <stephen@totalflood.com>
In-Reply-To: <4440121F.5020704@totalflood.com>
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

Stephen Carville wrote:
> shashi wrote:
>> Hi
>>
>> A small doubt about NFS3 in Linux . If i mount a NFS share (From NetApp
>>  , ONTAP 6.5 ) on a Linux machine with only ro,nolock options , then
>> still the NFS mount options like
>> bg,intr,hard,timeo,wsize,rsize,nfsvers,tcp are still applied ? If they
>> are applied , how can i check is those are applied or not ?
>>
>> In my Linux box , after mounting with only ro,nolock options .....
>>
>> [root@<hostname>]# mount | grep < Mount point>
>> <NFS server> on < Mount point >  type nfs (ro,nolock,addr=144.20.129.248)
>>
>> In this case , is other other options like
>> bg,intr,hard,timeo,wsize,rsize,nfsvers,tcp are applied ? if they are
>> applied , what are the default values ?
>>
>> Please answer to my question.
>>
> 
> "man nfs" lists the options and their defaults

Hi Stephen-

It's been my experience that the man pages on Linux are often quite out 
of date, and sometimes don't match the actual behavior of the commands 
available in each distribution.  Thus I recommend using a network trace 
to make sure.

-- 
corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
