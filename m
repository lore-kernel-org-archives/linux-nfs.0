From: "Jeff L. Smith" <jeff@atheros.com>
Subject: Re: Vaguely NFS related problem
Date: Thu, 12 Dec 2002 09:09:19 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DF8C2BF.8050109@atheros.com>
References: <3DF7EA94.20108@atheros.com>	<15863.61586.150820.505519@notabene.cse.unsw.edu.au>	<3DF7F663.30201@atheros.com> <15863.64480.756681.957850@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.atheros.com ([65.212.155.130] helo=atheros.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18MWpx-0003SZ-00
	for <nfs@lists.sourceforge.net>; Thu, 12 Dec 2002 09:09:25 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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

You are correct.  The only patch I applied was Trond's 
linux-2.4.18-NFS_ALL.dif and that is where the check is.  The actual 
patch was linux-2.4.18-svc_tcp.dif.  I'm not doing NFS-over-TPC, but 
this seems to be biting me anyway.

I plan to upgrade to 2.4.20 as soon as I can take the fileservers down 
long enough, but that will be a few weeks.  But then that begs the 
question, should I apply Trond's 2.4.20 patches?

Thanks,
Jeff

Neil Brown wrote:
> On Wednesday December 11, jeff@atheros.com wrote:
> 
>>I'm running a kernel I built from kernel.org source.  I found the 
>>message in linux-2.4.18/net/sunrpc/svcsock.c.
>>
>>
>>printk (KERN_WARNING "RPC: Unable to allocate resbuf from cache!\n");
> 
> 
> I think you should check again.  I did and I still cannot find that
> message:
> 
> % bzcat linux-2.4.18.tar.bz2 | grep 'Unable to allocate resbuf from cache'
> %
> 
> Are you sure they were *unpatched* kernel.org sources?
> 
> I suggest you unroll 2.4.20 and try that.
> 
> NeilBrown


-- 
Jeff Smith                                  Atheros Communications, Inc.
Hardware Manager                            529 Almanor Avenue
(408) 773-5257                              Sunnyvale, CA  94086



-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
