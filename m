From: "Peter Lojkin" <ia6432@inbox.ru>
Subject: Re: [repost] Another NFS related oops on smp servers
Date: Tue, 04 Feb 2003 18:58:25 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18g5Sr-000Gfd-00@f13.mail.ru>
References: <shsvg015bxx.fsf@charged.uio.no>
Reply-To: "Peter Lojkin" <ia6432@inbox.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx5.mail.ru ([194.67.57.15])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18g5TC-00018H-00
	for <nfs@lists.sourceforge.net>; Tue, 04 Feb 2003 07:58:46 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <shsvg015bxx.fsf@charged.uio.no>
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

Hello,

i understand your point and you are right. if i find the way to
reproduce this oops i'll check it with stock kernel. but since
stock kernel can't survive our work load for more then 2 hours
(because of vm and scheduler issues) i can't initiate kernel
upgrade on servers just to check if it oopses in a few weeks. and
now we have no free servers for long testing :(
do you have any suggestions on how to test it quick enough, so i
can test oops on our kernel then boot stock and check it there in
a couple of hours? how can i simulate rpc load (oops was in rpciod)?
nfs load we used last time doesn't trigger this oops...

btw, Neil posted a few rpc related patches about three weeks ago
can this be related?

-----Original Message-----
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "Peter Lojkin" <ia6432@inbox.ru>
Date: 03 Feb 2003 21:47:06 +0100
Subject: Re: [NFS] [repost] Another NFS related oops on smp servers

>     >> we had 3 nfs related oopses on our servers in 2 days. such
>     >> oopses never happened before. the kernel on oopsed servers is
>     >> basically 2.4.20aa1 + trond's waitq fix. one of the oopsed
>     >> servers had also trond's fix for another our oops problem,
>     >> discussed earlier.  the setup is:
> 
> I suggest you first try to reproduce that Oops on a stock kernel from
> ftp.kernel.org: 2.4.20aa1 is very unlikely to be used by too many of
> the developers (I certainly don't use it).
> 
> Cheers,
>   Trond



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
