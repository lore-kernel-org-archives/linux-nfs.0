From: Raphael Clifford <raphael@clifford.net>
Subject: Re: solaris server and firewalls
Date: Sun, 14 Sep 2003 19:32:24 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F64B438.7@clifford.net>
References: <200309121229.h8CCTWLR005929@buggy.badula.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ybg9-0003qV-00
	for <nfs@lists.sourceforge.net>; Sun, 14 Sep 2003 11:32:57 -0700
Received: from netmail02.services.quay.plus.net ([212.159.14.221])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19ybg9-0000xg-39
	for nfs@lists.sourceforge.net; Sun, 14 Sep 2003 11:32:57 -0700
To: Ion Badulescu <ionut@moisil.cs.columbia.edu>
In-Reply-To: <200309121229.h8CCTWLR005929@buggy.badula.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Ion Badulescu wrote:

>On Mon, 08 Sep 2003 12:09:41 +0100, Raphael Clifford <raphael@clifford.net> wrote:
>
>  
>
>>Is it safe to assume that
>>
>>a) There is no solution for using linux with solaris nfs servers with 
>>respect to the linux firewall and
>>b) There is no project working on this problem?
>>    
>>
>
>What you need here is a mount program that understands WebNFS. No change 
>is required for the kernel.
>  
>

Thanks.

>However, as far as I know there is no mount program for Linux that
>supports WebNFS. Amd tried to implement it at some point, but the idea
>quickly died off for lack of interest and users. Maybe I'll have another 
>try at it some day, but if you're not using amd anyway then there is no 
>point in wasting my time...
>  
>

I will happily use anything on the client side that will work.  Thanks 
very much for having a look at this.  I think a solution would be really 
useful. Especially as the internet is such an unpleasant place at the 
moment it seems a shame to have to open your firewall more than is 
strictly necessary :)

>  
>
>>If so, would it be a good idea to add this to the HOWTO?
>>    
>>
>
>Probably.
>
>Ion
>[amd co-maintainer]
>
>  
>
Cheers,
Raphael




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
