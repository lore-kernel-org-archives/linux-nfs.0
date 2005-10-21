From: Simon Kelley <srk@sanger.ac.uk>
Subject: Re: NFS port use.
Date: Fri, 21 Oct 2005 17:15:33 +0100
Message-ID: <43591425.1050608@sanger.ac.uk>
References: <4357C75C.8050805@sanger.ac.uk> <1129828136.9882.11.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESzYr-0006Ui-Ex
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 09:16:05 -0700
Received: from smtp.sanger.ac.uk ([193.62.203.215])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ESzYk-0007ZH-1K
	for nfs@lists.sourceforge.net; Fri, 21 Oct 2005 09:16:02 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1129828136.9882.11.camel@lade.trondhjem.org>
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
> to den 20.10.2005 klokka 17:35 (+0100) skreiv Simon Kelley:
> 
> 
>>logger: tcp        0      0 bc-4-3-09.internal.:988 ecs2:sunrpc 
>>    TIME_WAIT  -
> 
> 
> This is probably the "mount" program probing the portmapper for the
> supported NFS versions.

That looks likely: I checked the source, and it uses  bindresvport(). It 
looks like that can pick any port < 1024.
> 
> 
>>At this point I need help: my reasoning is wrong somewhere and I can't 
>>get any furher. Can anybody clarify things and tell me how to keep the 
>>NFS client subsystem away from port 988?
> 
> 
> Why can't you just ensure that start your daemon before you start NFS?

Possibly, but the dependencies are rather complex: it would be a case of 
"create a new start up order with daemon after NFS", not just "move 
daemon before NFS."

Thanks for you help.


Cheers,

Simon




-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
