From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: High Availability NFS Proposal
Date: Tue, 24 Sep 2002 14:17:47 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15759.59243.99514.345924@notabene.cse.unsw.edu.au>
References: <neilb@cse.unsw.edu.au>
	<15748.23840.351420.134476@notabene.cse.unsw.edu.au>
	<200209231353.g8NDru530832@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    lmb@suse.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17th92-0006gj-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Sep 2002 21:17:57 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.132] == wireless-132.wireless.cse.unsw.EDU.AU)
	(for <James.Bottomley@steeleye.com>)
	(for <nfs@lists.sourceforge.net>) (for <lmb@suse.de>) By tone With
	Smtp ; Tue, 24 Sep 2002 14:17:48 +1000
To: James Bottomley <James.Bottomley@steeleye.com>
In-Reply-To: message from James Bottomley on Monday September 23
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

On Monday September 23, James.Bottomley@steeleye.com wrote:
> neilb@cse.unsw.edu.au said:
> > Any progress on this?... The idea seems quite sound. My only
> > suggestion would be not to depend on the existance of a program in /
> > var/lib/nfs, but rather to have such a program specified as a command
> > line argument.  It makes it more explicit. 
> 
> Not yet...I was hoping to have this ready for our HA NFS in RHAS2.1, but the 
> time scales wouldn't line up.  I'll probably have time to get back to it in 
> October.

"The best laid plans..." and all that. :-)

> 
> I'll make the program directory be an explicit configuration option, thanks.
> 
> > Also, the need for this support in mountd will almost certainly go
> > away in 2.6 (that is what I am working on at the moment) but ofcourse
> > 2.4 is going to be around for a while so it is probably still worth
> > while. 
> 
> Yes, historically the 2.2 kernel was still being released up to a year after 
> 2.4 came out.  How are you planning to change mountd? make the kernel do the 
> authentication checks?

I haven't give a lot of thought to the exact changes to mountd, but
basically it will do what it currently does, but also listen on
a connection from the kernel.
The kernel will say 
  "I got a request from xx.yy.zz.ww, who is that?"
and mountd will tell the kernel about client "fred" which has that IP
address.
Then the kernel will say
  "I got a filehandle from fred with a 0xnnmmnnmm filesystem
  identifier. Where is that"
and mountd will tell the kernel about whichever export point for that
client matches the filehandle.

The old tools will still work on the new kernel (as well as they work
currently) and hopefully the new tools will work on old kernels
(though that isn't quite so high a priority).  I hope to start
submitting some of this stuff in October after I have had a week off.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
