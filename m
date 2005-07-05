From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: Linux client with MS SFU server
Date: Tue, 5 Jul 2005 20:42:17 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0507052031450.30139@maggie.lkpg.cendio.se>
References: <Pine.LNX.4.61.0507051838180.28175@maggie.lkpg.cendio.se>
 <42CACE6A.6090005@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-1704289037-1120588937=:30139"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.92] (helo=sc8-sf-mx2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpsNH-0004X3-RM
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 11:42:27 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DpsNF-0003OY-IQ
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 11:42:27 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <42CACE6A.6090005@redhat.com>
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

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-1704289037-1120588937=:30139
Content-Type: TEXT/PLAIN; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

On Tue, 5 Jul 2005, Peter Staubach wrote:

>> I'm trying to use the Linux NFS client with a Microsoft "Services For =
UNIX"=20
>> (SFU) server. The SFU version if 2.2. The server is actually a HP=20
>> Storageworks 1000s NAS server.

> Does this server need to be configured with the uid and maybe gid of th=
e=20
> user to be accessing files on the file system?  I have seen some=20
> situations, typically with Microsoft servers, that need to be accessed=20
> using a specific uid/gid combination.  Since these systems don't have=20
> the concept of uid and gid anyway, perhaps this is required here.

Well, yes. The server has a "User Name Mapping" feature. It can build map=
s=20
based on a NIS server source, for example. This is what I'm using. This i=
s=20
all documented in the NAS 1000s administration guide.

There's a component called "NFS Authentication Software" (sfucustom.msi)=20
that, according to the guide, needs to be installed on all PDCs and BDCs.=
=20
First, I didn't think this was necessary, but perhaps it is. I wonder wha=
t=20
this software actually does...


--=20
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-1704289037-1120588937=:30139--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
