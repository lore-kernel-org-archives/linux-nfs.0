From: "Pierre Lombard" <lombard.pierre@gmail.com>
Subject: Re: nfs over ssh : invalid protocol
Date: Mon, 8 Jan 2007 14:34:53 +0100
Message-ID: <f992145d0701080534r3b979de3yea805c59509ad672@mail.gmail.com>
References: <36900.193.178.136.53.1168256160.squirrel@altern.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H3ueM-0008Vp-Je
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 05:34:56 -0800
Received: from wr-out-0506.google.com ([64.233.184.231])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H3ueN-0007Ja-4Y
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 05:34:56 -0800
Received: by wr-out-0506.google.com with SMTP id i20so2578149wra
	for <nfs@lists.sourceforge.net>; Mon, 08 Jan 2007 05:34:54 -0800 (PST)
To: "oudoubah@altern.org" <oudoubah@altern.org>
In-Reply-To: <36900.193.178.136.53.1168256160.squirrel@altern.org>
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

On 1/8/07, oudoubah@altern.org <oudoubah@altern.org> wrote:

> I try to mount a nfs share over ssh with this commands (in a script) :
> ssh -f -L${NFSPORT}:${IPSERVER}:2049 -L${NFSMOUNTPORT}:${IPSERVER}:32767
> -l root ${IPSERVER} sleep 60
> mount -t nfs -o
> tcp,sync,rsize=8192,wsize=8192,soft,timeo=60,port=$NFSPORT,mountport=$NFSMOUNTPORT
> $NOMSERVER:/$REPSERVER $REP
>
> The tunnel is OK. The mount command works on some servers, but on other
> servers i have an error message. Here is what i see on the term :
> ssh -f -L38000:10.0.0.1:2049 -L38001:10.0.0.1:32767 -l save 10.0.0.1 sleep 60
> [OK]
> mount -t nfs -o
> tcp,sync,rsize=8192,wsize=8192,soft,timeo=60,port=38000,mountport=38001
> localhost:/images /tmp/save.11601
> mount to NFS server 'localhost' failed: possible invalid protocol.
> [KO]

> There is a firewall between the two servers, and only the port 22 and 111
> are open.
>
> Do you have any idea?

Maybe mountd is not running on port 32767 for those very servers - did
you check with rpcinfo ?

-- 
Pierre

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
