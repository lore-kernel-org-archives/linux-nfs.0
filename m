From: Frank van Maarseveen <F.vanMaarseveen@inter.NL.net>
Subject: Re: fsid syntax
Date: Fri, 9 Aug 2002 00:15:34 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020809001534.A1578@iapetus.localdomain>
References: <200208071711.00712.bernd-schubert@web.de> <shsk7n2d70y.fsf@charged.uio.no> <200208071830.54734.bernd-schubert@web.de> <15697.33669.398331.848444@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from grootstal.nijmegen.internl.net ([217.149.192.7])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cvdS-0001EZ-00
	for <nfs@lists.sourceforge.net>; Thu, 08 Aug 2002 15:20:02 -0700
Received: from iapetus.localdomain by grootstal.nijmegen.internl.net
	via 1Cust231.tnt59.rtm1.nl.uu.net [213.117.36.231] with ESMTP for <nfs@lists.sourceforge.net>
	id AAA21995 (8.8.8/1.3); Fri, 9 Aug 2002 00:19:52 +0200 (MET DST)
Received: (from inet1@localhost)
	by iapetus.localdomain (8.11.6/8.11.6) id g78MFYF09289
	for nfs@lists.sourceforge.net; Fri, 9 Aug 2002 00:15:34 +0200
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
In-Reply-To: <15697.33669.398331.848444@notabene.cse.unsw.edu.au>; from neilb@cse.unsw.edu.au on Thu, Aug 08, 2002 at 06:31:01AM +1000
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

On Thu, Aug 08, 2002 at 06:31:01AM +1000, Neil Brown wrote:
> 
> (*)  I really don't think that basing the fsid on the device number is
> at all sensible.  Afterall, that is what we are trying to avoid.
> Just pick a number, any number.

The number depends on the goal of specifying an fsid at all. Example:
Say you want to move the disk to a new system without affecting current
mounts. It is possible to use IP numbers for fsids and to set multiple
addresses on a NIC, for every exported filesystem. So when the disk or
partition is moved to a different system, the IP addresses have to move
to the NIC of the other system as well.

Actually I experimented with this some time ago (using a home brew fsid
kind of patch).


-- 
Frank


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
