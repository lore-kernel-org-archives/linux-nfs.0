From: Ryan Sweet <rsweet@atos-group.nl>
Subject: Re: e1000 intel driver bug (which impacts nfs)
Date: Mon, 3 Jun 2002 10:36:41 +0200 (MEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.30.0206031035420.17232-100000@ats-admn-0.atos-group.nl>
References: <20020603002819.A5501@stud.ntnu.no>
Reply-To: Ryan Sweet <rsweet@atos-group.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: jason andrade <jason@dstc.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [62.58.73.254] (helo=ats-core-0.atos-group.nl)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17EnXA-0001ua-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Jun 2002 01:49:48 -0700
To: <nfs@lists.sourceforge.net>
In-Reply-To: <20020603002819.A5501@stud.ntnu.no>
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

On Mon, 3 Jun 2002, Thomas Lang=E5s wrote:

> We've also got problems with nfs-hangs when transfering large files (ie.
> files around 300-400M, sometime we have to go a bit higher tho, like
> 2GB-3GB files, but it's always possible to trigger this. However, we
> don't need to be jumping through hoops to "fix it", after a min or so,
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
