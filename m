From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: nfs performance: read only/gigE/nolock/1Tb per day
Date: Mon, 22 Apr 2002 20:52:23 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0204222037530.16783-100000@kenzo.iwr.uni-heidelberg.de>
References: <shssn5noik3.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
   "'jason andrade'" <jason@dstc.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zivT-0000Zw-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Apr 2002 11:52:35 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <shssn5noik3.fsf@charged.uio.no>
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

On 22 Apr 2002, Trond Myklebust wrote:

> What might perhaps be happening is that the cards are somehow getting
> messed up due to data flooding. Have you tried playing around with
> driver parameters such as 'max_interrupt_work', 'max_rx_desc' and/or
> other interrupt-related variables? (see 'modinfo -p <module>' for the
> list of supported paramenters)

In case of network problems, some more info can be obtained from 
/proc/net/; f.e. /proc/net/dev can give some ideea about low level 
(driver) problems, where the most interesting might be "Rx overruns"
(the computer can't process packets as fast as they arrive and has to drop 
them as soon as the Rx ring becomes full - if your network driver has such 
parameter like "max_rx_desc" it should be increased). I don't know how to 
interpret all the data that is there, but either using the source or 
asking the Linux network developers at netdev@oss.sgi.com might help.

"max_interrupt_work" should not be modified unless a message like "ethx: 
Too much work in interrupt!" is logged by the kernel. In some cases, 
increasing "max_interrupt_work" without also increasing the Rx ring size 
would not help...

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
