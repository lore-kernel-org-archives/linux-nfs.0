From: Walter Faleiro <curtorkar@sancharnet.in>
Subject: Re: Rpc timeout error
Date: Thu, 18 Nov 2004 08:18:03 -0500
Message-ID: <419CA10B.7030404@sancharnet.in>
References: <419C564F.4040508@sancharnet.in>
 <1132270797.23464.581.camel@seki.nac.uci.edu> <419C838E.3030408@sancharnet.in>
 <1132275006.23464.612.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfsmailinglist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EcwGy-0000c6-Jw
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 18:46:44 -0800
Received: from bgl1mr1-a-fixed.sancharnet.in ([61.1.128.45])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EcwGw-0007YD-Sw
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 18:46:44 -0800
Received: from [172.16.20.58] ([220.227.185.226])
 by bgl1mr1-a-fixed.sancharnet.in
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTPA id <0IQ400D06QDKEU@""> for nfs@lists.sourceforge.net; Fri,
 18 Nov 2005 08:16:36 +0530 (IST)
In-reply-to: <1132275006.23464.612.camel@seki.nac.uci.edu>
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
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

Dan Stromberg wrote:

>In that case:
>
>http://dcs.nac.uci.edu/~strombrg/NFS-troubleshooting-2.html
>
>On Thu, 2004-11-18 at 06:12 -0500, Walter Faleiro wrote:
>  
>
>>Dan Stromberg wrote:
>>
>>    
>>
>>>On Thu, 2004-11-18 at 02:59 -0500, Walter Faleiro wrote:
>>> 
>>>
>>>      
>>>
>>>>Hi,
>>>>I am having a linux 7.2 system serving as a nfs server. I can mount the 
>>>>shares normally on other clients except one, which is Fedora Core 4. I 
>>>>get this error when I try to mount the nfs share,
>>>>Mount:RPC:Timed out.
>>>>
>>>>Is there any setting on FC4 that prevents nfs mounts?
>>>>   
>>>>
>>>>        
>>>>
>>>iptables?
>>>
>>> 
>>>
>>>      
>>>
>>>>--Walter
>>>>
>>>>
>>>>-------------------------------------------------------
>>>>This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
>>>>Register for a JBoss Training Course.  Free Certification Exam
>>>>for All Training Attendees Through End of 2005. For more info visit:
>>>>http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
>>>>_______________________________________________
>>>>NFS maillist  -  NFS@lists.sourceforge.net
>>>>https://lists.sourceforge.net/lists/listinfo/nfs
>>>>
>>>>   
>>>>
>>>>        
>>>>
>>> 
>>>
>>>      
>>>
>>Iptables are disabled on both pc's Disabled iptables on both pc's.
>>
>>    
>>
>
>
>
>-------------------------------------------------------
>This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
>Register for a JBoss Training Course.  Free Certification Exam
>for All Training Attendees Through End of 2005. For more info visit:
>http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>
>  
>
Thanks Dan,
running nmap put up an error saying hostname to ip could not be 
resolved. Put the entry in the /etc/hosts file and got it running.

--Walter


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
