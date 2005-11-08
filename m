From: Alan Glait <aglait@renatre.org.ar>
Subject: Re: Errors ...
Date: Tue, 08 Nov 2005 15:45:42 -0300
Message-ID: <4370F256.6030503@renatre.org.ar>
References: <4370AB14.9020203@renatre.org.ar>	 <1131460555.32482.4.camel@lade.trondhjem.org>	 <4370C459.5050600@renatre.org.ar>	 <1131465035.32482.37.camel@lade.trondhjem.org>	 <4370CB53.2000006@renatre.org.ar> <1131466365.32482.40.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZYSQ-0001jj-NM
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 10:44:34 -0800
Received: from host132.200-45-109.telecom.net.ar ([200.45.109.132] helo=gate.renatre.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EZYSP-0008Qn-5A
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 10:44:34 -0800
Received: from mx2.renatre.org.ar (mx2.renatre.org.ar [192.168.1.4])
	by gate.renatre.org (8.12.10/8.12.10) with ESMTP id jA8IiELs028127
	for <nfs@lists.sourceforge.net>; Tue, 8 Nov 2005 15:44:14 -0300
Received: from [192.168.1.5] (unknown [192.168.1.5])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.renatre.org.ar (Postfix) with ESMTP id 9749E5C1E
	for <nfs@lists.sourceforge.net>; Tue,  8 Nov 2005 15:55:38 -0300 (ART)
In-Reply-To: <1131466365.32482.40.camel@lade.trondhjem.org>
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

Now, everything is ok:
in the client: load average: 0.06, 0.15, 0.18
and I can see the nfs`s filesystem. But in the server I steel getting:
svc: unknown version (0)

I will change the on-board ethernet card in this server. May be this the 
problem??

Trond Myklebust wrote:

>On Tue, 2005-11-08 at 12:59 -0300, Alan Glait wrote:
>  
>
>>Ok ... when it happend i will test the comunication between the servers 
>>....
>>    
>>
>
>Thanks.
>
>  
>
>>I will add to the kernel :
>>Provide client support for the NFSv3 ACL protocol extension
>>Provide server support for the NFSv3 ACL protocol extension
>>    
>>
>
>This isn't really necessary unless you want to use ACLs. The server
>should be able to return the appropriate error to the client, and the
>client will stop probing.
>
>Cheers,
>  Trond
>
>
>
>-------------------------------------------------------
>SF.Net email is sponsored by:
>Tame your development challenges with Apache's Geronimo App Server. Download
>it for free - -and be entered to win a 42" plasma tv or your very own
>Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
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
