From: Eric Whiting <ewhiting@amis.com>
Subject: Re: 2.4.18: NFS_ALL patch greatly hurting UDP speed
Date: Wed, 20 Mar 2002 17:33:44 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C992A68.877C36E0@amis.com>
References: <200203210020.g2L0KrB13635@moisil.badula.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from dermis.amis.com ([207.141.5.253])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nqWm-0007ej-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Mar 2002 16:34:00 -0800
To: Ion Badulescu <ionut@cs.columbia.edu>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Ion Badulescu wrote:
> 
> On Wed, 20 Mar 2002 11:23:43 -0700, Eric Whiting <ewhiting@amis.com> wrote:
> 
> > ==THIRD TEST
> > Same setup as second test, but using dd instead of bonnie
> >
> > mohawk/test> time dd if=/dev/zero of=file bs=1024k count=1
> > 1+0 records in
> > 1+0 records out
> > 0.000u 0.030s 0:05.06 0.5%      0+0k 0+0io 136pf+0w
> >
> > About 200k/s on a 100Mbit network -- not very good.
> 
> Umm... no. I don't recall your setup (and you didn't specify it
> in your email), but if this is the same setup as Lee's (GigE
> bridged into 100Mbit), then you don't really have a 100Mbit network.
> What you have is a GigE network with 90% packet loss. 200k/s is
> actually pretty good in that case.

The only variable I change is the kernel on the linux client. The
network is 100M at both the server and the client. (gigE inbetween --
but I've tested with suns on the local switch and found the same
results)

The default kernel runs 5-10M/s on writes. Reboot to a 2.4.18 with
NFS_ALL and you see 200K/s on writes. Same network. Same UDP transport.
Just something goofy going on.



> 
> This is what Trond has been trying to say all along: UDP is a losing
> proposition for this kind of setup. The only way you can make it work
> sort of ok is by slowing it down and thus penalizing the rest of us
> with sane setups.
> 
> Just use TCP and be happy.

Yes.. That is what Sun does. I'm starting to do that more and more. I've
been using Neil's knfsd and tcp patches on some boxes. (but I'm not
using those patches on these recent tests that I've been reporting)


eric

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
