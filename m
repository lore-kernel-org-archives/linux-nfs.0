From: Donavan Pantke <avatar@dcr.net>
Subject: Re: Re: NFS as a Cluster File System.
Date: Thu, 9 Jan 2003 18:45:36 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200301091845.36063.avatar@dcr.net>
References: <F43H06Ym8Es5FEnoLH80000317f@hotmail.com>
Reply-To: avatar@dcr.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 216-7-67-178.ip.win.net ([216.7.67.178] helo=richard.dpapt.spellboundnet.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18WmKx-0003lR-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Jan 2003 15:43:47 -0800
To: "Lorn Kay" <lorn_kay@hotmail.com>, lmb@suse.de,
	nfs@lists.sourceforge.net, linux-ha@muc.de
In-Reply-To: <F43H06Ym8Es5FEnoLH80000317f@hotmail.com>
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

On Thursday 09 January 2003 18:13, Lorn Kay wrote:

>
> Sorry, still confused about what a "CFS" really is. In "In Search Of
> Clusters" Gregory Pfister takes the position that a distributed file sy=
stem
> is what he calls a valid "single system image" file system, what I woul=
d
> take to mean a cluster file system (though he doesn't use those words).
>
> I guess you are saying a clustered file system isn't necessarily suppor=
ting
> a cluster of application servers but is itself stored on a cluster. (A
> single server can be the only server using a cluster file system.) ?
>

=09Typically, the term CFS refers to a set of servers that work on the sa=
me=20
storage at the same time. What this means is that my central storage syst=
em=20
could have multiple servers mounting a file system at the same time.=20
Currently, preforming this is still in development; the difficulty is tha=
t=20
all nodes have to tell each other in some way about exactly what they're=20
doing to keep from corrupting the data on storage. Until this matures for=
=20
production use (It's my presonal opinion that there are still too many bu=
gs=20
in current implementations), the next best answer is for a highly availab=
le=20
cluster of servers that handle data requests. This is where NFS comes in.=
=20
Although I agree that in some applications this isn't workable with NFS, =
I've=20
found it to be quite a boon. At my workplace, we have a great many machin=
es=20
accessing common data. We started with a M$ cluster using SMB, but the na=
ture=20
of the protocol means that when the cluster fails, each client can't acce=
ss=20
currently open files. they have to close and re-open each handle. The=20
stateless nature of NFSv3 and v2 is stateless. This means that a cluster =
can=20
fail over and clients simply pause requests untile the filesystem is=20
accessible again. Not a good soution for applications with very high resp=
onse=20
time requirements, but it works for us. BTW: When describing clusters her=
e=20
I'm referring to a active-passive pair of servers where resources move wh=
en a=20
failure has been detected.

=09Donavan Pantke


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
