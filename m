From: Steffen Persvold <sp@scali.com>
Subject: Re: NFS clients behind a masqueraded gateway
Date: Thu, 25 Apr 2002 19:24:52 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.30.0204251922190.16930-100000@elin.scali.no>
References: <Pine.LNX.4.30.0204180946500.10622-100000@elin.scali.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from elin.scali.no ([62.70.89.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 170mzy-0004jX-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Apr 2002 10:25:38 -0700
To: NFS Mailinglist <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.30.0204180946500.10622-100000@elin.scali.no>
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

Hi again,

I hate to bother you guys again with this problem, but do you have any
ideas (haven't received any response so far) ?

Answers highly appreciated.

On Thu, 18 Apr 2002, Steffen Persvold wrote:

> Hi all,
>
> I'm experiencing some problems with a cluster setup. The cluster is set up
> in a way that you have a frontend machine configured as a masquerading
> gateway and all the compute nodes behind it on a private network (i.e the
> frontend has two network interfaces). User home directories and also other
> data directories which should be available to the cluster (i.e statically
> mounted in the same location on both frontend and nodes) are located on
> external NFS servers (IRIX and Linux servers). This seems to work fine
> when the cluster is in use, but if the cluster is idle for some time (e.g
> over night), the NFS directories has become unavailable and trying to
> reboot the frontend results in a complete hang when it tries to unmount
> the NFS directories (it hangs in a fuser command). The frontend and all
> the nodes are running RedHat 7.2, but with a stock 2.4.18 kernel (plus
> Trond's seekdir patch, thanks for the help BTW).
>
> Ideas anyone ?
>
> Thanks in advance,
>

Regards,
-- 
  Steffen Persvold   | Scalable Linux Systems |   Try out the world's best
 mailto:sp@scali.com |  http://www.scali.com  | performing MPI implementation:
Tel: (+47) 2262 8950 |   Olaf Helsets vei 6   |      - ScaMPI 1.13.8 -
Fax: (+47) 2262 8951 |   N0621 Oslo, NORWAY   | >320MBytes/s and <4uS latency


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
