From: Eric Whiting <ewhiting@amis.com>
Subject: Re: huge number of intr/s on large nfs server
Date: Tue, 15 Oct 2002 14:51:56 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DAC7FEC.C858A014@amis.com>
References: <5CA6F03EF05E0046AC5594562398B9160C773E@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dermis.amis.com ([207.141.5.253])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181Yf1-0003pM-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 13:51:27 -0700
To: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
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

I'm running 93MBytes/s on gigE copper (testing using a 1000M file).
(jumbo frames enabled)

eric



"Heflin, Roger A." wrote:
> 
>         Something else,
> 
>         if you are dd a 10mb file on the local machine that is all going to be in cache, so
>         the rate will be horribly incorrect.
> 
>         Also these are gigabit copper cards correct?  Gigabit copper cards only run
>         a max of 50MB/second, so getting 35MB/second over one of them is pretty good.
> 
>         I am getting 1500cs/second and 6500ints/second at about 8MB/second to
>         the network.
> 
>         I get 3600cs/second and 15000ints/second at about 20MB/second to the
>         network.
> 
>         How fast of IO are you getting on the local machine?
> 
>                                                         Roger
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?http://www.viaverio.com/
consolidator/osdn.cfm


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
