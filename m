From: Raphael Clifford <raphael@clifford.net>
Subject: Re: solaris server and firewalls
Date: Tue, 23 Sep 2003 16:43:35 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F706A27.3050302@clifford.net>
References: <Pine.LNX.4.44.0309221148530.28207-100000@guppy.limebrokerage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A1pKq-0004Wa-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Sep 2003 08:44:16 -0700
Received: from ptb-mailc04.plus.net ([212.159.14.210])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.22)
	id 1A1pKp-0005Wd-CI
	for nfs@lists.sourceforge.net; Tue, 23 Sep 2003 08:44:15 -0700
To: Ion Badulescu <lists@news.cs.columbia.edu>
In-Reply-To: <Pine.LNX.4.44.0309221148530.28207-100000@guppy.limebrokerage.com>
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

>On Sun, 14 Sep 2003, Raphael Clifford wrote:
>
>  
>
>>Ion Badulescu wrote:
>>
>>    
>>
>>>However, as far as I know there is no mount program for Linux that
>>>supports WebNFS. Amd tried to implement it at some point, but the idea
>>>quickly died off for lack of interest and users. Maybe I'll have another 
>>>try at it some day, but if you're not using amd anyway then there is no 
>>>point in wasting my time...
>>> 
>>>      
>>>
>>I will happily use anything on the client side that will work.  Thanks 
>>very much for having a look at this.  I think a solution would be really 
>>useful. Especially as the internet is such an unpleasant place at the 
>>moment it seems a shame to have to open your firewall more than is 
>>strictly necessary :)
>>    
>>
>
>All right, I've implemented support for webnfs mounting in the latest beta 
>(b4) of am-utils 6.1. [This could also go into the FAQ, I guess.]
>
>However, if you're not currently using an automounter, switching to amd 
>could be somewhat of a tall order... It would be nice if webnfs support 
>was implemented in mount(8), as it's simple enough, but I won't be the one 
>to do it.
>
>Ion
>
>  
>
Ion,

That is fantastic news.  Just out of interest, who should I bug about 
mount? I couldn't seem to find a suitable maintainer listed anywhere.
Cheers,
Raphael




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
