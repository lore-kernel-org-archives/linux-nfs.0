From: =?iso-8859-1?q?Johan=20Thelin?= <e8johan@yahoo.se>
Subject: Re: Problems when mounting
Date: Wed, 23 Oct 2002 15:34:13 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021023133413.70814.qmail@web14702.mail.yahoo.com>
References: <1035375104.3903.18.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web14702.mail.yahoo.com ([216.136.224.119])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184LeI-0007CZ-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 06:34:14 -0700
To: "David B. Ritch" <dritch@hpti.com>,
  Network File System <nfs@lists.sourceforge.net>
In-Reply-To: <1035375104.3903.18.camel@localhost>
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

I don't have showmount on the client, but if I run it
on the host to itself (through the 192.168.1.1 IP, not
127.0.0.1) it looks good.

The reason that I want to have NFS up and running is
that the client only has a FLASH filesystem that I
need to build on a host and the download. Instead of
that I want to do cross compilation etc from the host
and simply run the apps I develop over NFS. When that
works, I'll put the apps in the FLASH once and for
all.

/Johan

 --- "David B. Ritch" <dritch@hpti.com> wrote: 
> Just in case you missed something in rpcinfo - did
> you run "showmount -e
> 192.168.1.2" on the client?
> 
> Also, I believe that the two systems need to be able
> to resolve
> hostnames for each other in order to mount; 
> however, I would expect to
> see an error message more clearly indicative of an
> authentication issue
> in that case.
> 
> On Wed, 2002-10-23 at 06:05, Johan Thelin wrote:
> >   I'm running an embedded system running Linux
> 2.5.21
> > and a host system (x86) running RedHat 7.3.
> > The two units are connected by a twisted TP cable
> and
> > the IP communication works (they can ping each
> other
> > and traceroute knows the way).
> >   The host machine has been configured to share a
> > folder over NFS in /etc/exports, the only line
> reads: 
> > 
> > /home/johan/nfsexport 192.168.1.2(rw)
> > 
> >   The specified IP is the one used by the target
> > system. I have followed the NFS HOWTO and
> succesfully
> > got the daemons running (rpcinfo -p looks good).
> When
> > I try to mount from the target by using the line:
> > 
> > mount 192.168.1.1:/home/johan/nfsexport /tmp/local
> > 
> >   I get the following problem:
> > 
> > mount: Mounting 192.168.1.1:/home/johan/nfsexport
> on
> > /tmp/local failed: No such file or directory
> > 
> >   I have verified that /tmp/local exists as a
> > directory and so does /home/johan/nfsexport on the
> > host.
> > 
> >   I would be very thankful for some constructive
> > input, or even an solution. I cannot find this
> error
> > message documented anywhere, so I don't know where
> to
> > begin.
 

_____________________________________________________
Gratis e-mail resten av livet på www.yahoo.se/mail
Busenkelt!


-------------------------------------------------------
This sf.net emial is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
