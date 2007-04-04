From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: can not start NFSv4 with Kerberos 5
Date: Wed, 4 Apr 2007 11:47:25 -0400
Message-ID: <4d569c330704040847h4f97b7d6gb9a8da78b5016d29@mail.gmail.com>
References: <1175595021.3798.19.camel@localhost.localdomain>
	<89c397150704030446id0db9b1h30e20cfba0f5182a@mail.gmail.com>
	<1175676220.3572.21.camel@milan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Phillip <phuang@plasmon.cn>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HZ7hl-0003cx-Pu
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 08:47:25 -0700
Received: from wr-out-0506.google.com ([64.233.184.233])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HZ7hn-0007Wq-2T
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 08:47:28 -0700
Received: by wr-out-0506.google.com with SMTP id i20so338319wra
	for <nfs@lists.sourceforge.net>; Wed, 04 Apr 2007 08:47:26 -0700 (PDT)
In-Reply-To: <1175676220.3572.21.camel@milan>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 4/4/07, Phillip <phuang@plasmon.cn> wrote:
>
> [root@nfsv4 ~]# mount -t nfs4 -o sec=krb5 192.168.123.63:/ /e
> Warning: rpc.gssd appears not to be running.
> mount: Broken pipe
>
> I find that the rpc.gssd is running:
> [root@nfsv4 ~]# ps -ef | grep rpc.gss
> root      5053  4854  0 16:31 pts/2    00:00:00 rpc.gssd -fvvv
> root      5065  4909  0 16:34 pts/3    00:00:00 grep rpc.gss

The Warning message is because rpc.gssd was not started from the
script which writes the pid file.  Not a problem here.

> there's the following lines in /var/log/message:
>
> Apr  4 11:11:00 nfsv4 rpc.svcgssd[4742]: WARNING: handle_nullreq: failed
> parsing request
> Apr  4 11:11:25 nfsv4 rpc.svcgssd[4742]: WARNING: handle_nullreq: failed
> parsing request

See if svcgssd with more debugging (-vvv) gives a better clue.

Is this a 64-bit machine?  What versions of nfs-utils and supporting
libraries (libgssapi, librpcsecgss) is this with?

K.C.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
