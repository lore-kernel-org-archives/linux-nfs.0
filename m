From: Matt Schillinger <mschilli@vss.fsi.com>
Subject: Re: [Fwd: Re: rpc.mountd problems]
Date: 25 Jun 2003 12:33:47 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1056562429.3941.49.camel@mosix>
References: <1056396464.31466.25.camel@mosix>
	<16119.28036.546786.260128@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-66-136-174-212.dsl.stlsmo.swbell.net ([66.136.174.212] helo=esds.vss.fsi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19VE7p-0006TF-00
	for <nfs@lists.sourceforge.net>; Wed, 25 Jun 2003 10:32:05 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16119.28036.546786.260128@gargle.gargle.HOWL>
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



On Mon, 2003-06-23 at 16:13, Neil Brown wrote:
> On  June 23, mschilli@vss.fsi.com wrote:
> > 
> > I am forwarding this message to the list to see if anyone knows why I am
> > getting these 'Invalid argument' messages when doing an exportfs -arv..
> > It seems to be connected to only one of the export directories..
> > 
> > Matt  
> > -----Forwarded Message-----
> > 
> > > From: Matt Schillinger <mschilli@vss.fsi.com>
> > > To: Steve Dickson <SteveD@RedHat.com>
> > > Subject: Re: [NFS] rpc.mountd problems
> > > Date: 23 Jun 2003 13:57:45 -0500
> > > 
> > > 
> > > 
> > > Here is the results of the exportfs -arv.  The exportfs did NOT fix the
> > > stall to clients, followed by a 'Permission Denied', with nothing
> > > registering in messages on the NFSD Server. 
> > > 
> > > The Server is now running 2.4.20 kernel with a CWD patch for nfsd to
> > > work correctly with older version of IRIX.  This problem also existed in
> > > 2.4.19. 
> > > 
> > > Do file descriptors ever come into the picture? 
> > > 
> > > [root@thor root]# exportfs -arv 
> > > exporting loki:/mnt/test 
> > > unexporting philemon:/export/terrex_prototyping from kernel 
> > > philemon:/export/terrex_prototyping: Invalid argument 
> > > unexporting zippie:/export/terrex_prototyping from kernel 
> > > zippie:/export/terrex_prototyping: Invalid argument 
> > > unexporting rico:/export/terrex_prototyping from kernel 
> 
> The simplest explanation for this is that /export/terrex_prototyping
> was exported *before* a filesystem was mounted there.
> e.g.
>     exportfs zippie:/export/terrex_prototyping
>     mount /dev/sda1 /export/terrex_prototyping
>     exportfs -avr
> 
> exportfs is trying to unexport the newly mounted filesystem, and the
> kernel is saying that it isn't exported.
> Try unmounting it and running "exportfs" again.

But it WAS mounted prior to exportfs.. hmm.. could /var/lib/nfs/rmtab
entries existing prior to exportfs cause a problem?

I was reading about statd, and the --name option, and came across a
patch by Bruce Allan that deals with statd and multiple interface
machines..
	I am not really sure if it's related, but I DO have a multi interfaced
machine..

The config is like this:

Three gigabit interfaces on three separate subnets. 
	in dns, there is only the name thor.vss.fsi.com that corresponds to the
ips... But another note, is that those ips are bound to ip aliases
(eth0:0, etc).
	The actual interface ip addresses all have names associated (thor-200,
thor-400, thor-20).

	Could this cause a problem??

	One last shot in the dark is that 2 of our Solaris 8 boxes, that act as
nfs clients, are ALSO multi homed, on the same subnets.. Might that
interact badly?

Matt
> 
> > > 
> > > 
> > > The problem is, I don't keep the primary nfs shares in /etc/exports.. 
> > > (exportfs -arv actually cleared all exports except the ONE that is in
> > > exports that is there to make sure that nfsd starts at boot).
> > > 
> > > >From that though, I immediately ran an exportfs -o
> > > rw,async,no_root_squash @vss_grp:/export/vss/db/mv22
> > > 
> > > and
> > > exportfs -o rw,async,no_root_squash @vss_grp:/export/terrex_prototyping
> > > 
> > > On the nfs server.. this went fine, but the problem still existed on the
> > > clients (permission denied after stall).
> 
> Presumably the filehandle the client has doesn't match the filesystem
> you have exported.  This could similarly be caused by exporting before
> mounting.
> 
> > > 
> > > only a restart of rpc.mountd fixed the problem..
> > > 
> 
> Yep.  rpc.mountd thinks it has exported "/export/terrex_prototyping"
> and so wont try to export it again.  When you kill and restart it, it
> forgets that it has already exported it, and trys again.  This time it
> exports the mounted filesystem and the clients become happy.
> 
> > > 
> > > 
> > > QUESTION: is the "Invalid argument" in the exportfs -arv due to the fact
> > > that the particular mountpoint does not exist in /etc/exports??
> > > 
> 
> Not directly.
> 
> 
> NeilBrown




-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
