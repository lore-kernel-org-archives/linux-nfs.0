From: pwitting@Cyveillance.com
Subject: Re: nfs performance problem
Date: Wed, 6 Nov 2002 12:08:59 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <D38AFB3080F3D311807300B0D0203E53033A931C@MERCURY>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [63.100.163.69] (helo=mercury.cyveillance.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189Tg7-0007Be-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Nov 2002 09:09:19 -0800
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

> From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
> On Tue, Nov 05, 2002 at 08:55:41PM +0100, poczta.dotcom.pl wrote:
> > > How is local performance?

> > local read/writes are ok

> > > What filesystem do you use?

> > reiserfs on top of lvm (to be able to get snapshots)

I'm just going to throw my two cents in here. It sounds like the box is
getting a lot of random IO (~500k maildirs) which means he is most likely
seeing a LOT of seek issues, and RAID 5 is probably a really bad choice.
Cheap controllers and fast RAID 5 just don't go together, there's too much
math going on (the parity bit moves, remember) Matt, you really need to
trust the folks on the list on this and try it. You'll lose some capacity
(drop from 800GB to 480GB per array), but hopefully the performance boost
will be worth it.

Now, on the plus side, you're already using LVM, so I have a better idea
than RAID 1+0 for your situation. Build six RAID 1 arrays, then use LVM to
create a single logical volume out of the group. The randomness should
ensure that if your server receives 4 simultaneous read/write requests, they
will each have their own "spindle", an there will be no performance robbing
back and forth seeking, meaning the requests get handled faster, meaning
there's less chance for the system to start thrashing with seek requests.

I usually think of each RAID volume as a "virtual spindle", capable of
handling 1 request at a time. While each individual transaction might be
slower, (no striping to speed things up) there's six lanes to handle the
requests. Server thinking versus Workstation thinking.

Hopefully you can experiment with this, If this things production already it
may be too late.


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
