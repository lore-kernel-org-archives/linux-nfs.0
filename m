From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS mount option - noac forces sync even if async is sp
	ecified, and no warning is given
Date: Mon, 3 Feb 2003 11:10:00 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D55289@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18flyx-0005fu-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Feb 2003 11:10:15 -0800
To: "'Heflin, Roger A.'" <Roger.A.Heflin@conocophillips.com>
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

> I run the following command:
> 
> mount -t nfs -o rw,hard,lock,intr,noac,async 
>      hoepld31:/ptmp/hoepld31 /tmpmnt/ptmp/hoepld31
> 
> And then cat /proc/mounts:
> 
> hoepld31:/ptmp/hoepld31 /tmpmnt/ptmp/hoepld31 nfs 
> rw,sync,v3,rsize=8192,
>      wsize=8192,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,intr,
>      udp,noac,lock,addr=hoepld31 0 0
> 
> Note that async is specified on the mount line and 
> /proc/mounts specifies that sync was used.  If I don't use 
> the async option the same thing happens.  This is with 
> 2.4.21pre3 NFSALL and utils-1.0.1-1 (as included by RH7.3)  
> for the client.  The server is 2.4.19 NFSALL 
> (an earlier NFSALL), I don't believe the server makes a 
> difference on the issue of the client not seeming to 
> recogonize the sync 
> option.   The client and server are both originally based on RH7.3.

noac without sync writes doesn't make much sense, does it?
noac is used to cause multiple clients to share files pretty
tightly.  even if client A is aggressively checking a server
for changes to a file, it will not detect changes unless
all the other clients send their writes as submitted by the
app, rather than delaying them.

solaris noac has always behaved this way, and Linux noac
has behaved like this since around 2.4.7.

> If I remove the noac option, then the async option seems to 
> be honered, but not with the noac option on the line, is this 
> the documented 
> behavior?  And should something give a warning since one user 
> specified options overrides another user specified option in a 
> very nonobvious way?

noac is a synonym for "actimeo=0,sync" which is the behavior
of least surprise in this case.  if you look at the Solaris
man page which describes noac, you will see that Solaris's noac
behaves this way.  maybe the Linux mount_nfs man page hasn't
been updated to reflect this behavior.

> The write performance stinks rather badly with the sync option 
> enabled, and I could see why you *might* want to force it 
> with noac, but not if the user is attempting to override the 
> sync option with async.

synchronous writes are always slow.

perhaps the real bug is that noac,async doesn't work the way
you expect it.  i can think of only one instance where this
might be desired: if the writing application resides on the
file server.

> SYNC is specified on the exports line on the remote server, 
> and my understanding was that you want sync on the exports line, and 
> async on the mount line on the client, but I cannot seem to 
> get it to take async on the mount line (no error is given, 
> but it appears to have been ignored, trying a known bad 
> option -say nosync does give a error saying bad option).

sync on the server side is not the same as sync on the client
side.  take a look at the NFS FAQ or review the archives of
this list to see why this is the case.


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
