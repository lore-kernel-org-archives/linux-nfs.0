From: Alan Glait <aglait@renatre.org.ar>
Subject: Re: Errors ...
Date: Tue, 08 Nov 2005 12:59:15 -0300
Message-ID: <4370CB53.2000006@renatre.org.ar>
References: <4370AB14.9020203@renatre.org.ar>	 <1131460555.32482.4.camel@lade.trondhjem.org>	 <4370C459.5050600@renatre.org.ar> <1131465035.32482.37.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZVrI-0002r5-Tc
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 07:58:04 -0800
Received: from host132.200-45-109.telecom.net.ar ([200.45.109.132] helo=gate.renatre.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EZVrI-0008LN-Fm
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 07:58:05 -0800
Received: from mx2.renatre.org.ar (mx2.renatre.org.ar [192.168.1.4])
	by gate.renatre.org (8.12.10/8.12.10) with ESMTP id jA8FvnLs020375
	for <nfs@lists.sourceforge.net>; Tue, 8 Nov 2005 12:57:49 -0300
Received: from [192.168.1.5] (unknown [192.168.1.5])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.renatre.org.ar (Postfix) with ESMTP id C28035C1E
	for <nfs@lists.sourceforge.net>; Tue,  8 Nov 2005 13:09:11 -0300 (ART)
In-Reply-To: <1131465035.32482.37.camel@lade.trondhjem.org>
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

Ok ... when it happend i will test the comunication between the servers 
....

I will add to the kernel :
Provide client support for the NFSv3 ACL protocol extension
Provide server support for the NFSv3 ACL protocol extension

its ok ??

Trond Myklebust wrote:

>On Tue, 2005-11-08 at 12:29 -0300, Alan Glait wrote:
>  
>
>>That the strange thing... There is not a process at 100% ... and the 
>>first 10 process are at most 1% but the nfs doesnt respond.
>>    
>>
>
>Sounds to me as if Steve is right: your network access from that machine
>is somehow broken.
>Are you able to ping the server from the client when this happens? Can
>you also, for instance, log in from that client?
>
>Cheers,
>  Trond
>
>  
>
>>Alan
>>
>>Trond Myklebust wrote:
>>
>>    
>>
>>>On Tue, 2005-11-08 at 10:41 -0300, Alan Glait wrote:
>>> 
>>>
>>>      
>>>
>>>>Hi !
>>>>I have an Fedora core 4 exporting a directory. It have 2.6.13 kernel.
>>>>I mount it on Red Hat Enterprise Linux AS release 3 with 2.4.21-4.ELsmp 
>>>>kernel. In the server, I get "svc: unknown version (0)" everytime. In 
>>>>the client i get :nfsd: last server has exited
>>>>   
>>>>
>>>>        
>>>>
>>>That is probably 2.6.13 probing for ACL support on the server. It should
>>>be harmless.
>>>
>>> 
>>>
>>>      
>>>
>>>>                                                            nfsd: 
>>>>unexporting all filesystems
>>>>                                                            nfsd: last 
>>>>server has exited
>>>>                                                            nfsd: 
>>>>unexporting all filesystems
>>>>                                                            portmap: 
>>>>server localhost not responding, timed out
>>>>all time.
>>>>There is no problem but sometimes in the client it start to consume a 
>>>>lot of the processors and I cant to stop it. The service stop ok but it 
>>>>doesnt "release the usage" of th precessors ... in a top, a see iowait 
>>>>at 100% or 98% .
>>>>   
>>>>
>>>>        
>>>>
>>>Could you explain what you mean by "iowait at 100%"? Normally, iowait is
>>>a process state, (a sleep state actually).
>>>
>>>Which process is in this state?
>>>
>>>Cheers,
>>> Trond
>>>
>>>
>>>
>>>-------------------------------------------------------
>>>SF.Net email is sponsored by:
>>>Tame your development challenges with Apache's Geronimo App Server. Download
>>>it for free - -and be entered to win a 42" plasma tv or your very own
>>>Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
>>>_______________________________________________
>>>NFS maillist  -  NFS@lists.sourceforge.net
>>>https://lists.sourceforge.net/lists/listinfo/nfs
>>>
>>>
>>> 
>>>
>>>      
>>>
>>
>>-------------------------------------------------------
>>SF.Net email is sponsored by:
>>Tame your development challenges with Apache's Geronimo App Server. Download
>>it for free - -and be entered to win a 42" plasma tv or your very own
>>Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/nfs
>>    
>>
>
>
>
>  
>



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
