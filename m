From: canon@pookie.nersc.gov
Subject: Re: NFS read ok, write ok, simultaneous R+W=TERRIBLE
Date: Thu, 05 Dec 2002 16:04:07 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200212060004.gB6047El007311@pookie.nersc.gov>
References: <CFEAJJEGMGECBCJFLGDBGEIHCJAA.hammer@clarkisland.com>
Cc: "Jake Hammer" <hammer@clarkisland.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pookie.nersc.gov ([128.55.16.113])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18K5jI-0002wD-00
	for <nfs@lists.sourceforge.net>; Thu, 05 Dec 2002 15:48:28 -0800
To: "NFS" <nfs@lists.sourceforge.net>
In-Reply-To: Your message of "Thu, 05 Dec 2002 10:35:14 PST."
             <CFEAJJEGMGECBCJFLGDBGEIHCJAA.hammer@clarkisland.com>
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


> We're launching 20 occurences of DD each producing a 10GB zero filled file
> from /dev/zero. Since the cache is only 2GB, we have to be breaking it with
> just one file, nevermind all of them. Then we launch 20 occurences of DD
> again and read all the files back into /dev/null. Then the the local test
> that makes me believe that NFS is broken: 20 occurences of DD reading and 20
> occurences of DD writing simultaneously is just as fast as the other tests.
> So, local disk performance sustains excellent throughput numbers on all of
> these *local* operations.
> 
> Now try the same testing with 20 NFS mounted clients each DD'ing a 10GB
> file. Great read, great write, horrible read/write.
> 

Okay, that sounds good.  This sounds similar to the tests we do,
but we use iozone.  So it seems more likely you are seeing
an NFS issue.

> 
> 
> 2.2.19 or 2.4.19?
> 

It actually was a 2.2.19.  This was a while back.  We did
tests software raid under 2.4 though and saw similar 
behaviour.  We haven't revisited this though.  There
are probably improvements in the md code, so it may
not be an issue still.

> 
> Have you changed your bdflush settings at all? If so, can we compare
> settings? Playing with bdflush makes huge impacts to our local disk
> performance.
> 

We do adjust this, but I'm going to check that we are using optimal
settings.  What values are you using?


> Thanks,
> 
> Jake
> 
> 

Likewise,

--Shane


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
