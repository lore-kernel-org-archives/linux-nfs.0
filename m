From: Mark Manuel Cruz Ramos <mmramos@singtel.com>
Subject: RE: e1000 intel driver bug (which impacts nfs)
Date: Mon, 3 Jun 2002 16:54:39 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <2B53AD95B05ED411BE8C0008C7FA33F00467B5DA@EXSP13A>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Cc: jason andrade <jason@dstc.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from orion2.singtel.com ([165.21.21.188] helo=orion2.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17EndM-0002IG-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Jun 2002 01:56:12 -0700
To: "'Ryan Sweet'" <rsweet@atos-group.nl>, nfs@lists.sourceforge.net
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


I had this problem also using the standard install of rh 7.2.  but =
after
upgrading the kernel to 2.4.18, everything is fine already.

-----Original Message-----
From: Ryan Sweet [mailto:rsweet@atos-group.nl]
Sent: Monday, June 03, 2002 4:37 PM
To: nfs@lists.sourceforge.net
Cc: jason andrade
Subject: Re: [NFS] e1000 intel driver bug (which impacts nfs)


On Mon, 3 Jun 2002, Thomas Lang=E5s wrote:

> We've also got problems with nfs-hangs when transfering large files =
(ie.
> files around 300-400M, sometime we have to go a bit higher tho, like
> 2GB-3GB files, but it's always possible to trigger this. However, we
> don't need to be jumping through hoops to "fix it", after a min or =
so,
> it's ok again. It seems to me like there's a VM problem or something.

Does the problem happen with local I/O also, or only with nfs?



--=20
Ryan Sweet <ryan.sweet@atosorigin.com>
Atos Origin Engineering Services
http://www.aoes.nl


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
