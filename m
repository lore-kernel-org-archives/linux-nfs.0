From: Matt Schillinger <mschilli@vss.fsi.com>
Subject: [Fwd: Re: rpc.mountd problems]
Date: 23 Jun 2003 14:27:44 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1056396464.31466.25.camel@mosix>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-66-136-174-212.dsl.stlsmo.swbell.net ([66.136.174.212] helo=esds.vss.fsi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19UWxG-00066K-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 12:26:18 -0700
Received: from mosix.vss.fsi.com (mosix [198.51.27.89])
	by esds.vss.fsi.com (8.11.6+Sun/8.9.1) with ESMTP id h5NJQBK20180
	for <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 14:26:11 -0500 (CDT)
To: nfs@lists.sourceforge.net
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


I am forwarding this message to the list to see if anyone knows why I am
getting these 'Invalid argument' messages when doing an exportfs -arv..
It seems to be connected to only one of the export directories..

Matt  
-----Forwarded Message-----

> From: Matt Schillinger <mschilli@vss.fsi.com>
> To: Steve Dickson <SteveD@RedHat.com>
> Subject: Re: [NFS] rpc.mountd problems
> Date: 23 Jun 2003 13:57:45 -0500
> 
> 
> 
> Here is the results of the exportfs -arv.  The exportfs did NOT fix the
> stall to clients, followed by a 'Permission Denied', with nothing
> registering in messages on the NFSD Server. 
> 
> The Server is now running 2.4.20 kernel with a CWD patch for nfsd to
> work correctly with older version of IRIX.  This problem also existed in
> 2.4.19. 
> 
> Do file descriptors ever come into the picture? 
> 
> [root@thor root]# exportfs -arv 
> exporting loki:/mnt/test 
> unexporting philemon:/export/terrex_prototyping from kernel 
> philemon:/export/terrex_prototyping: Invalid argument 
> unexporting zippie:/export/terrex_prototyping from kernel 
> zippie:/export/terrex_prototyping: Invalid argument 
> unexporting rico:/export/terrex_prototyping from kernel 
> rico:/export/terrex_prototyping: Invalid argument 
> unexporting max:/export/terrex_prototyping from kernel 
> max:/export/terrex_prototyping: Invalid argument 
> unexporting kosh:/export/terrex_prototyping from kernel 
> kosh:/export/terrex_prototyping: Invalid argument 
> unexporting iscream:/export/terrex_prototyping from kernel 
> iscream:/export/terrex_prototyping: Invalid argument 
> unexporting daffy:/export/terrex_prototyping from kernel 
> daffy:/export/terrex_prototyping: Invalid argument 
> unexporting barge:/export/terrex_prototyping from kernel 
> barge:/export/terrex_prototyping: Invalid argument 
> unexporting thing1.vss.fsi.com:/export/terrex_prototyping from kernel 
> thing1.vss.fsi.com:/export/terrex_prototyping: Invalid argument 
> unexporting pinky:/export/terrex_prototyping from kernel 
> pinky:/export/terrex_prototyping: Invalid argument 
> unexporting daedalus:/export/terrex_prototyping from kernel 
> daedalus:/export/terrex_prototyping: Invalid argument 
> unexporting hotrod:/export/terrex_prototyping from kernel 
> hotrod:/export/terrex_prototyping: Invalid argument 
> unexporting hummer:/export/terrex_prototyping from kernel 
> hummer:/export/terrex_prototyping: Invalid argument 
> unexporting brain:/export/terrex_prototyping from kernel 
> brain:/export/terrex_prototyping: Invalid argument 
> unexporting burns:/export/terrex_prototyping from kernel 
> burns:/export/terrex_prototyping: Invalid argument 
> unexporting pepe:/export/terrex_prototyping from kernel 
> pepe:/export/terrex_prototyping: Invalid argument 
> unexporting origin:/export/terrex_prototyping from kernel 
> origin:/export/terrex_prototyping: Invalid argument 
> unexporting jazz:/export/terrex_prototyping from kernel 
> jazz:/export/terrex_prototyping: Invalid argument 
> unexporting vis_cv2:/export/terrex_prototyping from kernel 
> vis_cv2:/export/terrex_prototyping: Invalid argument 
> unexporting thing2.vss.fsi.com:/export/terrex_prototyping from kernel 
> unexporting sunir:/export/terrex_prototyping from kernel 
> sunir:/export/terrex_prototyping: Invalid argument 
> unexporting shenzi:/export/terrex_prototyping from kernel 
> shenzi:/export/terrex_prototyping: Invalid argument 
> unexporting orion:/export/terrex_prototyping from kernel 
> orion:/export/terrex_prototyping: Invalid argument 
> unexporting jumpy:/export/terrex_prototyping from kernel 
> jumpy:/export/terrex_prototyping: Invalid argument 
> unexporting hermes:/export/terrex_prototyping from kernel 
> hermes:/export/terrex_prototyping: Invalid argument 
> unexporting esds:/export/terrex_prototyping from kernel 
> esds:/export/terrex_prototyping: Invalid argument 
> unexporting eos:/export/terrex_prototyping from kernel 
> eos:/export/terrex_prototyping: Invalid argument 
> unexporting dionysus:/export/terrex_prototyping from kernel 
> dionysus:/export/terrex_prototyping: Invalid argument 
> unexporting athena:/export/terrex_prototyping from kernel 
> athena:/export/terrex_prototyping: Invalid argument 
> unexporting apollo:/export/terrex_prototyping from kernel 
> apollo:/export/terrex_prototyping: Invalid argument 
> unexporting aaaa:/export/terrex_prototyping from kernel 
> unexporting philemon:/export/vss/db/mv22 from kernel 
> unexporting zippie:/export/vss/db/mv22 from kernel 
> unexporting rico:/export/vss/db/mv22 from kernel 
> unexporting max:/export/vss/db/mv22 from kernel 
> unexporting kosh:/export/vss/db/mv22 from kernel 
> unexporting iscream:/export/vss/db/mv22 from kernel 
> unexporting daffy:/export/vss/db/mv22 from kernel 
> unexporting barge:/export/vss/db/mv22 from kernel 
> unexporting thing1.vss.fsi.com:/export/vss/db/mv22 from kernel 
> unexporting pinky:/export/vss/db/mv22 from kernel 
> unexporting daedalus:/export/vss/db/mv22 from kernel 
> unexporting hotrod:/export/vss/db/mv22 from kernel 
> unexporting hummer:/export/vss/db/mv22 from kernel 
> unexporting brain:/export/vss/db/mv22 from kernel 
> unexporting burns:/export/vss/db/mv22 from kernel 
> unexporting pepe:/export/vss/db/mv22 from kernel 
> unexporting origin:/export/vss/db/mv22 from kernel 
> unexporting jazz:/export/vss/db/mv22 from kernel 
> unexporting thing2.vss.fsi.com:/export/vss/db/mv22 from kernel 
> reexporting loki:/mnt/test to kernel 
> [root@thor root]# 
> 
> 
> The problem is, I don't keep the primary nfs shares in /etc/exports.. 
> (exportfs -arv actually cleared all exports except the ONE that is in
> exports that is there to make sure that nfsd starts at boot).
> 
> >From that though, I immediately ran an exportfs -o
> rw,async,no_root_squash @vss_grp:/export/vss/db/mv22
> 
> and
> exportfs -o rw,async,no_root_squash @vss_grp:/export/terrex_prototyping
> 
> On the nfs server.. this went fine, but the problem still existed on the
> clients (permission denied after stall).
> 
> only a restart of rpc.mountd fixed the problem..
> 
> 
> 
> QUESTION: is the "Invalid argument" in the exportfs -arv due to the fact
> that the particular mountpoint does not exist in /etc/exports??
> 
> 
> Thanks for your help, 
> 
> Matt Schillinger 
> mschilli@vss.fsi.com
> 
> 
> On Mon, 2003-06-23 at 08:55, Steve Dickson wrote: 
> > Matt Schillinger wrote:
> > 
> > >I am doing rmtab modifications (adding) on rare cases, as part of a high
> > >availability configuration.. I am not actively touch any file except
> > >rmtab, and only adding to it as necessary to allow a second machine to
> > >takeover nfsservices.. but this problem has been occuring with no rmtab
> > >modification (except the nfs server's standard modifications).
> > >
> > Ok... When this happens again could you do a exportfs -arv instead of
> > killing mountd? Hopefully that will tell us if is or is not a export 
> > issue...
> > 
> > SteveD.
> > 
> > >
> > >
> > >
> > >On Sat, 2003-06-21 at 07:56, Steve Dickson wrote:
> > >  
> > >
> > >>Where the exports changed in some way? I sounds like one
> > >>got lost or removed...
> > >>
> > >>SteveD.
> > >>
> > >>Matt Schillinger wrote:
> > >>
> > >>    
> > >>
> > >>>	I am having problems with rpc.mountd. 
> > >>>
> > >>>I have found that after a while, mount requests cease to be honored.
> > >>>Clients see a stall when trying to do a file operation on an NFS
> > >>>mountpoint (ls for instance), followed by a 'Permission Denied'. On the
> > >>>NFS server, there is no long entries that show any activity of mountd or
> > >>>otherwise pointing to the Permission Denied. This is in a mixed
> > >>>environment of Linux, Irix 6.x, Solaris 6, 7, and 8, using automounting
> > >>>tools.
> > >>>
> > >>>On the NFS Server, /var/log/messages does not show any rpc.mountd
> > >>>activity at the point at which mount requests start stalling. I have
> > >>>bumped file descriptors for rpc.mountd from 512, to 1024, and now up to
> > >>>2048. 2048 is currently running (as of this morning), and has yet to
> > >>>fail, but it's only been running a short time. 512 and 1024 did not seem
> > >>>to help alot. I really don't even know if file descriptors are related.
> > >>>
> > >>>Killing rpc.mountd and restarting it causes mount operations to
> > >>>continue.
> > >>>
> > >>>Here is my configuration
> > >>>
> > >>>Dual Xeon 2.4Ghz
> > >>>2G RAM
> > >>>NICS Utilized: 3 - 1Gigabit Interfaces
> > >>>Clients: About 100 - mix of OS's. 
> > >>>Services: nfs (100 clients) - Samba (70-130 clients)
> > >>>There are two mountpoints served, and are primarily for Image
> > >>>Processing, so they do see a good amount of load. 
> > >>>Disks: Ataboy2 ATA Raid (RAID 5)
> > >>>Filesystem: Reiserfs
> > >>>
> > >>>Kernel: linux-2.4.19, with the fh32 patch for CWD issues with IRIX <
> > >>>6.5.13.
> > >>>nfs-utils-1.0.3
> > >>>
> > >>>
> > >>>
> > >>>
> > >>>Please let me know if there's anything else i can include to help solve
> > >>>this problem.
> > >>>
> > >>>
> > >>>
> > >>> 
> > >>>
> > >>>      
> > >>>
> > >>
> > >>-------------------------------------------------------
> > >>This SF.Net email is sponsored by: INetU
> > >>Attention Web Developers & Consultants: Become An INetU Hosting Partner.
> > >>Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
> > >>INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
> > >>_______________________________________________
> > >>NFS maillist  -  NFS@lists.sourceforge.net
> > >>https://lists.sourceforge.net/lists/listinfo/nfs
> > >>    
> > >>
> 
> 




-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
