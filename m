From: Danny Smith <dannys@cinesite.co.uk>
Subject: Re: linux 2.4.20 oops
Date: Tue, 29 Apr 2003 17:44:23 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EAEABE7.9070305@cinesite.co.uk>
References: <8147E1B07201DD41B6B9F0D31E07B384449055@srv-grp-s07.dev.atos.fr>	<3EAE498A.1000106@cinesite.co.uk> <87of2pxo37.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: =?ISO-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>,
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from scanman.cinesite.co.uk ([193.203.81.129])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AYE1-0002jD-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 09:45:01 -0700
To: Philippe Troin <phil@fifi.org>
In-Reply-To: <87of2pxo37.fsf@ceramic.fifi.org>
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


Philippe Troin wrote:

>Danny Smith <dannys@cinesite.co.uk> writes:
>  
>
>>We used this patch from Ulrich Weigand
>>(weigand@informatik.uni-erlangen.de), and haven't seen a problem
>>since. See the archives for full details - basically seems to be an
>>SMP race in rpc_delete_timer(). If you're not on an SMP system, it's
>>probably NOT the right fix.
>>    
>>
>
>Has this been pushed to 2.4.21?
>  
>
Not AFAIK.
 From the comments in the original post I saw, it looks like Trond did 
produce a similar patch, but I couldn't see anything when I was looking 
for a resolution to our problems. Perhaps it's worth waiting for more 
confirmation that this is
a) harmless in all cases, and
b) fixes the problems being seen
before trying to get this pushed up. I freely confess that I don't know 
enough of this code at this level to feel confident beyond "it works 
well for us".

Danny

-- 
Danny Smith
Senior Systems Administrator, Cinesite (Europe) Ltd
020 7973 4000 - x4055    /    dannys@cinesite.co.uk




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
