From: Hans-Peter Jansen <hpj@urpla.net>
Subject: Re: nfs errors clutter up logs after 2.4.20 -> 2.4.22-pre10
Date: Fri, 5 Sep 2003 13:05:43 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200309051305.43484.hpj@urpla.net>
References: <200308231404.34087.hpj@urpla.net> <200308262328.09975.hpj@urpla.net> <200308271250.09723.hpj@urpla.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19vEPU-0007LO-00
	for <nfs@lists.sourceforge.net>; Fri, 05 Sep 2003 04:05:48 -0700
Received: from moutng.kundenserver.de ([212.227.126.184])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19vEPT-0000b0-Ne
	for nfs@lists.sourceforge.net; Fri, 05 Sep 2003 04:05:47 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <200308271250.09723.hpj@urpla.net>
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

Hi Trond,

I've tried to #define RPC_RTO_MIN (HZ/8) also, but this doesn't 
change the picture.

Here are a few more random data points (sorry for the large holes,
I cannot keep the pace of you guys _all_ the time ;-):

With 2.4.20 and before, I noticed this message only when taking
down the server, which is expected.

While betatesting the current kernel of upcoming SuSE 9.0 (2.4.21-59), 
prepared for diskless in my 8.2 env. yesterday, it doesn't show this 
problem, too. It's a heavily tweaked 2.4.21 with many .22 fixes 
included. It happens for me with 2.4.22-pre10, so it smells like some 
changes in (late) 2.4.22 triggers it.

Pete

On Wednesday 27 August 2003 12:50, Hans-Peter Jansen wrote:
> Hi Trond,
>
> unfortunately, it hasn't fixed the phenomenon completely, but now
> it takes much longer to trigger it. After rebuilding and restarting
> tonight at 00:52, the first occurence was at 09:57, the next ones
> at 10:00 and 10:05.
>
> Do you think, it's worth playing with bigger RPC_RTO_MIN values?
>
> Cheers,
> Pete



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
