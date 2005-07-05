From: "dshaffer" <dshaffer@ssc-corp.com>
Subject: RE: Linux client with MS SFU server
Date: Tue, 5 Jul 2005 14:00:30 -0500
Message-ID: <7A16AC014E394147A587615D96BF666F897095@it.ssc>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dpsew-0005J2-Mk
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 12:00:42 -0700
Received: from 64-247-230-130.wan.networktel.net ([64.247.230.130])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1Dpseu-0000LD-TK
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 12:00:42 -0700
To: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>,
	"Peter Staubach" <staubach@redhat.com>
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


	It is used for mapping SID's to UID's and depending on your environment =
may need to be loaded to them, however a Getattr and a Readdir would be =
reading the same mappings. I am obviously prejudiced and think you could =
use a better one (see sig). You can get help from this newsgroup but the =
version you are using is very old and I am not sure what you will get:

http://groups-beta.google.com/group/microsoft.public.servicesforunix.gene=
ral?hl=3Den

	Even though you are not squashing root the UID 0 is treated differently =
from all other UID's. If the UID 0 is not mapped you are getting =
world/anonymous access. Even if you grant the machine root access if you =
have not mapped UID 0 I believe this is still the case. Also Getattr may =
be allowed as it is non-destructive and some NFS Clients do one as part =
of the Mount. If Getattr was denied the Mount would fail also.

Dan Shaffer
www.accessnfs.com


-----Original Message-----
From: Peter =C5strand [mailto:astrand@cendio.se]
Sent: Tuesday, July 05, 2005 1:42 PM
To: Peter Staubach
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] Linux client with MS SFU server


On Tue, 5 Jul 2005, Peter Staubach wrote:

>> I'm trying to use the Linux NFS client with a Microsoft "Services For =
UNIX"=20
>> (SFU) server. The SFU version if 2.2. The server is actually a HP=20
>> Storageworks 1000s NAS server.

> Does this server need to be configured with the uid and maybe gid of =
the=20
> user to be accessing files on the file system?  I have seen some=20
> situations, typically with Microsoft servers, that need to be accessed =

> using a specific uid/gid combination.  Since these systems don't have=20
> the concept of uid and gid anyway, perhaps this is required here.

Well, yes. The server has a "User Name Mapping" feature. It can build =
maps=20
based on a NIS server source, for example. This is what I'm using. This =
is=20
all documented in the NAS 1000s administration guide.

There's a component called "NFS Authentication Software" (sfucustom.msi) =

that, according to the guide, needs to be installed on all PDCs and =
BDCs.=20
First, I didn't think this was necessary, but perhaps it is. I wonder =
what=20
this software actually does...


--=20
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
