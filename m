From: Brian Pawlowski <beepy@netapp.com>
Subject: Re: Re: network storage solutions
Date: Thu, 15 May 2003 11:19:11 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200305151819.h4FIJBq19624@orbit-fe.eng.netapp.com>
References: <3EC3D370.5050406@lmco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: beowulf@beowulf.org, landman@scalableinformatics.com,
   nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19GNKK-0002LH-00
	for <nfs@lists.sourceforge.net>; Thu, 15 May 2003 11:19:36 -0700
In-Reply-To: <3EC3D370.5050406@lmco.com> from Jeff Layton at "May 15, 3 01:50:40 pm"
To: jeffrey.b.layton@lmco.com
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

It's not religious.

It's simple.

NFS servers (that I use) commit their data to persistent storage
before replying to the client.  This protects against simple data loss
in face of server reboots.  If they didn't do this, I could get
silent data loss or corruptions of data that my application may not be aware of
or recover from.

That's expected behaviour from hard mounts on a client to a server.

Soft mounts say "Try, but after N errors of transmission give up."

People use soft mounts for (1) improved performance (you can juice
up cheap servers by caching data), or (2) prevent hung clients
in face of unreliable networks and servers (when client is accessing
many NFS servers).

At Sun, I felt in the end soft mounts were a bad idea.  Better was "intr"
where at least user interaction could override "hard" mount guarantees,
and the user can make a choice of "screw my data".

Today, though, even the reboot persistence of data is inadequate
for many critical apps.  Commercial servers have RAID or mirroring,
clustered configs for eliminating single points of failure (and hung mounts),
etc.

> Joseph Landman wrote:
> 
> > On Thu, 2003-05-15 at 12:24, Jeff Layton wrote:
> > > Jeff Layton wrote:
> > >
> > > > Joe Landman wrote:
> > > >
> > > >> Note: the soft vs hard mount is a matter of "religion" to some 
> > folk.  I
> > > >> usually specify
> > > >>
> > > >
> > > >   I don't think it's really a religion. From what I've read,
> > > > the NFS guru's say that you have to use hard mounts to
> > > > guarantee data integrity (which I'm sure everyone wants
> > > > for a rw mounted filesystem). Here is one reference:
> > > >
> > > > http://www.netapp.com/tech_library/3183.html#3.
> >
> > I still maintain it is a religious preference.  Hard mounts can and will
> > crash client machines in the event of a server being permanently down.
> > Some folks want that behavior.  Some do not.  This is also a religious
> > war.
> >
> 
>    I'm cc-ing the NFS mailing list to get their input on this.
> However, let me say that I don't really view it as a religious
> preference. If I lose my server in a cluster, I don't mind
> losing the nodes (however, we've lost the NFS server
> before and never lost any of the nodes on a 288 node cluster
> even though they are hard mounted - strange).
>    Since we use our cluster for production work (please, I'm
> not trying to offend anyone), we HAVE to have non-corrupted
> data. This is why we use hard mounts with 'sync' as well as
> a few other options. The URL above to Chuck's paper has
> several examples of "good" mount options.
> 
> > Amazing how many of them occur.
> >
> > The way I and other who use soft mounts view it, data lossage occurs
> > when the server crashes, as you cannot guarantee (except with sync),
> > that the data was committed to disk.
> >
> 
> However, if I read Chuck's paper correctly, with soft mount
> you can get a soft time-out that can interrupt an operation
> but the client will continue then with corrupted data. Am I
> understanding this correctly? Therefore, the clients may be
> up, but now the data is corrupt and the appliation doesn't
> know it.
> 
> 
> > Worse, if you are using a
> > journaling fs on the NFS server side, to recover the fs, there may
> > require a roll-back of the fs state.  This would crash a transaction in
> > progress on the client with a hard mount and sync, and in a number of
> > cases, crash the kernel.  With a soft mount, and sync, you would get an
> > error.  Please note that this is a highly oversimplified version of what
> > really happens, and some may disagree with the statements.  Refer to the
> > source to see what happens.  Wont be reproduced here.
> >
> > Which one is more relevant to you is more a matter of preference than of
> > data security.  If your server crashes, you are going to lose
> > transactions in flight, written but not committed.  How the client
> > responds to those is a matter of preference.  This is where the
> > religious aspect crops up.
> >
> 
> I'm not sure... If the server crashes, I think this is true.
> But what if you get an interrupt. Soft mounts will allow
> the application to continue with corrupted data while hard
> mounts will produce an error, but not corrupt data (I think).
> 
> Jeff
> 
> > [...]
> >
> > > >> as options on my mounts.  I prefer the soft mount for a number of
> > > >> reasons, most notably stability of the whole cluster is not a 
> > function
> > > >> of the least stable server.
> >
> > This really opens up some of the points of how to handle errors in the
> > cluster shared file system.
> >
> > -- 
> > Joseph Landman <landman@scalableinformatics.com>
> >
> 
> 
> -- 
> Jeff Layton
> Senior Engineer - Aerodynamics and CFD
> Lockheed-Martin Aeronautical Company - Marietta
> 
> "Is it possible to overclock a cattle prod?" - Irv Mullins
> 
> 
> 
> 
> -------------------------------------------------------
> Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
> The only event dedicated to issues related to Linux enterprise solutions
> www.enterpriselinuxforum.com
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
