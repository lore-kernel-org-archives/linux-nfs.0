From: Andrew Ryan <andrewr@nam-shub.com>
Subject: Re: 2.4.20-rc1 NFS/TCP client (still) hangs running
  dbench 2.0
Date: Sat, 02 Nov 2002 21:21:02 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.0.2.1.0.20021102211350.0291eec0@pop.sfrn.dnai.com>
References: <0211011318080N.01583@stinkpad060501>
 <3DC2E7B6.6090400@collab.net>
 <0211011318080N.01583@stinkpad060501>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from moe.sfrn.dnai.com ([208.59.199.25])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 188D9v-0008FB-00
	for <nfs@lists.sourceforge.net>; Sat, 02 Nov 2002 21:18:51 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <15810.63756.640223.676492@charged.uio.no>
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

At 10:58 PM 11/1/02 +0100, Trond Myklebust wrote:

>It is probably just the (known) accounting error in the 'retransmit'
>statistics. Try applying the patch
>
> 
>http://www.fys.uio.no/~trondmy/src/2.4.20-pre9/linux-2.4.20-01-call_start.dif
>
>if it bothers you.

Yes, you are right, it seems the counter is broken, and performance is 
fine. I did bonnie++ runs with 2.4.20rc1 kernels with and without the 
call_start patch, and didn't see any significant difference.

But, it does bother me since I want to be able to diagnose network errors 
if I ever have them, and with a busted counter it will be impossible to 
tell what my real error rate is. Can the call_start patch go to Marcelo for 
2.4.20rc2?

After a bonnie run with the call_start patch, I get this, which is much 
better :)

$ nfsstat -c
Client rpc stats:
calls      retrans    authrefrsh
1648050    0          0


thanks,
andrew



-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
