From: Andrei Maslennikov <andrei@caspur.it>
Subject: Re: NFS performance issue - P3 vs P4
Date: Fri, 11 Oct 2002 22:42:00 +0000 (   )
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.3.95a.1021011220934.18295B-100000@kiwi.caspur.it>
References: <shs1y6witaj.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, g.palumbo@caspur.it
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from kiwi.caspur.it ([193.204.5.49])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1808Tv-000287-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Oct 2002 15:42:07 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs1y6witaj.fsf@charged.uio.no>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


On 11 Oct 2002, Trond Myklebust wrote:

> >>>>> " " == Andrei Maslennikov <andrei@caspur.it> writes:
> 
>      > with all the recent patches. On clients, we use RH kernel
>      > 2.4.18-10smp.
> 
> Has a known UDP bug that can cause it to flood servers. Netapp over
> Gigabit has previously been seen to be vulnerable. Please either use a
> TCP connection to the Netapp, or try the appended patch.


Hi Trond, and thanks for the hint.

I have just checked that the patch you mentioned was applied
in the Red Hat's 2.4.18-14 kernel released with Red Hat 8.0
("linux-2.4.18-udp-fix.patch"). I have then upgraded to 2.4.18-14
on P4 client and - bingo: I see a stable 34 MB/sec as in case of P3!  
Lots of thanks! 

We'll also mount "tcp" from NetApp on older clients that still 
may have that bug - thanks again for your suggestion. Actually,
I now understand that we have seen indeed several server flooding
cases with F760 on Gigabit (and we were looking for the problem 
elsewhere...).  

Best regards - Andrei.

PS One point still remains unclear - how then it could be explained that
   P3 client was not manifesting any problem with P3 server? It had 
   exactly the buggy 2.4.18-10smp, like P4. Maybe it may be attributed
   to a higher (2 Ghz against 1 Ghz of P3's) CPU clock on P4 client?  





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
