From: "Eff Norwood" <enorwood@effrem.com>
Subject: RE: huge number of intr/s on large nfs server
Date: Tue, 15 Oct 2002 19:54:08 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFEAJJEGMGECBCJFLGDBEEJGCFAA.enorwood@effrem.com>
References: <5CA6F03EF05E0046AC5594562398B9160C773E@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <bogdan.costescu@iwr.uni-heidelberg.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cynaptic.com ([128.121.116.181])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181eK6-0005QO-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 19:54:14 -0700
To: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>,
   <nfs@lists.sourceforge.net>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B9160C773E@poexmb3.conoco.net>
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

Hi Roger,

> 	if you are dd a 10mb file on the local machine that is all
> going to be in cache, so
> 	the rate will be horribly incorrect.

Didn't do that - did a 10mb DD from 30 simultaneous network clients. I also
tried 30 simultaneous local processes of 5GB dd each and got *much* better
local disk performance than NFS performance once again.

> 	Also these are gigabit copper cards correct?  Gigabit
> copper cards only run
> 	a max of 50MB/second, so getting 35MB/second over one of
> them is pretty good.

They are copper - Syskonnect. Where did you get the idea that they only do
50MB/sec from? If they're gigabit, I expect them to be able to do 250MB/sec
full duplex.

> 	I am getting 1500cs/second and 6500ints/second at about
> 8MB/second to
> 	the network.
>
> 	I get 3600cs/second and 15000ints/second at about 20MB/second to the
> 	network.
>
> 	How fast of IO are you getting on the local machine?

If I do a large single DD, I see 140MB/sec local write. If I do multiple
local dd's, I see 105MB/sec write. I didn't measure the intr/s yet but will
do.

Eff




-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
