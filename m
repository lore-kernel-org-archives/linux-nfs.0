From: "Eff Norwood" <enorwood@effrem.com>
Subject: RE: huge number of intr/s on large nfs server
Date: Thu, 17 Oct 2002 09:59:13 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFEAJJEGMGECBCJFLGDBMEMKCFAA.enorwood@effrem.com>
References: <004401c275e1$cf940170$2a060e09@beavis>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cynaptic.com ([128.121.116.181])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 182DzZ-0007QV-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Oct 2002 09:59:25 -0700
To: "Andrew Theurer" <habanero@us.ibm.com>
In-Reply-To: <004401c275e1$cf940170$2a060e09@beavis>
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

Hi Andrew,

> Eff, do you happen to know the cpu utilization for the local mulitple dd
> test?  I am concerned that the evms_raid5d is eating up a lot of
> cpu, which
> is fine for the local dd test, but may be too much when nfsd is running.

That's a really good question and a point I hadn't made. The EVMS Raid 5
process seems to stay in the 12-20% utilization range for both local and NFS
dd's. For local, dd consumes as much of the remaining cpu as it can get
(~80%) with an occasional interruption from kswapd-very steady and even. For
NFS, the nfsd's (16 of them) in total also consume as much of the remaining
cpu as they can get (~80%) BUT they fluctuate from 80% to 0% then back 80%
all the time. I think much of the performance loss is caused by these
"pulsations" because the box is just sitting around idle waiting for the
next pulse of nfsd activity.

I tried everything in this:

http://people.redhat.com/alikins/system_tuning.html

except playing "Crazy Train" by Ozzy Ozbourne and have as of yet not been
able to get the nfsd's to stop "pulsating". I think that would help things a
lot. If I need to play "Crazy Train" I can arrange that. :)

Thanks,

Eff




-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
