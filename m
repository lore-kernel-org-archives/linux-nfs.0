From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: async vs. sync
Date: Thu, 25 Nov 2004 09:24:12 +1100
Message-ID: <16805.2572.79895.275921@cse.unsw.edu.au>
References: <482A3FA0050D21419C269D13989C611307CF4B56@lavender-fe.eng.netapp.com>
	<41A3AFC4.6080404@int-evry.fr>
	<41A4D6C5.2060902@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lever, Charles" <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CX5Ym-0005gV-CQ
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 14:24:24 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CX5Yl-0002Vq-2D
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 14:24:24 -0800
To: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
In-Reply-To: message from jehan.procaccia on Wednesday November 24
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

On Wednesday November 24, jehan.procaccia@int-evry.fr wrote:
> 
> However now the tar extraction goes very fast but stops 1 or 2  or  and 
> restart fast -> there are some hangs. Here with a 16MB journal I got 15 
> hangs of 1-2 seconds, with a 128 MB I get only 3 hangs but they last 4or 
> 5 seconds. I checked at a momment of an hang on the nfs server with 
> iostat, and disk utilisation goes from a few % to  316 % in the exemple 
> below (for 128 MB journal withing the 4 seconds hangs it goes to 4700 % !)
> Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s    wkB/s 
> avgrq-sz avgqu-sz   await  svctm  %util
> /dev/emcpowerl2
>              0.00 150.67 97.33 224.00  768.00 3018.67   384.00  
> 1509.33    11.78    33.33   19.79   9.83 316.00
> 
> Maybe it hangs because the journal commits on the SP ! ?
> 

It hangs because of some clumsy code in ext3 that no-one has bothered
to fix yet - I had a look once but it was a little beyond the time I
had to spare.

When information is written to the journal, it stays in memory as well
and is eventually written out to the main filesystem using normal
lazy-flushing mechanisms (data is pushed out either due to memory
pressure or because it has been idle for too long).
When ext3 wants to add information to the head of the journal, it
needs to clean up the tail to make space.
If it finds that the data that was written to the tail is already
safe in the main filesystem, it just frees up some of the  tail and
starts using it for a new head.
HOWEVER, if it finds that the data in the tail hasn't made it to the
main filesystem, it flushes *ALL* of the data in the journal out to
the main filesystem. (It should only flush some fraction or fixed
number of blocks or something).  This flushing causes a very
noticeable pause.  The larger the journal, the less often the flush is
needed, but the longer the flush lasts for.

There are two ways to avoid this pause.  One I have tested and works
well.  The other only just occurred to me and I haven't tried.

The untested one involves making the journal larger than main memory.
If it is that large, then memory pressure should flush out journal
blocks before the journal wraps back to them, and so the flush should
never happen.  However such a large journal may cause other problems
(slow replay) as mentioned in my other email.

The way that works if to adjust the "bdflush" parameters so that data
is flushed to disk more quickly.  The default is to flush data once it
is 30 seconds old.  If you reduce that to 5 seconds, the problem goes
away. 

For 2.4, I put
vm.bdflush =  30 500 0 0 100 500 60 20 0

in my /etc/sysctl.conf, which is equivalent to running
  echo   30 500 0 0 100 500 60 20 0 > /proc/sys/vm/bdflush

For 2.6, I assume you would
   echo 500 > /proc/sys/vm/dirty_expire_centisecs
but I haven't tested this.


> Well, finally, is this safer in terms of performances to externalize 
> journal than using async export ?

Absolutely, providing you trust the hardware that you are storing your
journal on.
An external journal is perfectly safe.
async export is not.

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
