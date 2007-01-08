From: oudoubah@altern.org
Subject: Re: nfs over ssh : invalid protocol
Date: Mon, 8 Jan 2007 16:18:01 +0100 (CET)
Message-ID: <60484.193.178.136.53.1168269481.squirrel@altern.org>
References: <36900.193.178.136.53.1168256160.squirrel@altern.org>
	<f992145d0701080534r3b979de3yea805c59509ad672@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H3vHS-00048Y-CO
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 06:15:18 -0800
Received: from altern.org ([80.67.174.57] helo=filer2.altern.org ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H3vHJ-0005FM-Mi
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 06:15:11 -0800
In-Reply-To: <f992145d0701080534r3b979de3yea805c59509ad672@mail.gmail.com>
To: "Pierre Lombard" <lombard.pierre@gmail.com>
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


>> ssh -f -L38000:10.0.0.1:2049 -L38001:10.0.0.1:32767 -l save 10.0.0.1
>> sleep 60
>> mount -t nfs -o
>> tcp,sync,rsize=8192,wsize=8192,soft,timeo=60,port=38000,mountport=38001
>> localhost:/images /tmp/save.11601
>> mount to NFS server 'localhost' failed: possible invalid protocol.

>> There is a firewall between the two servers, and only the port 22 and
>> 111
>> are open.
>>

>
> Maybe mountd is not running on port 32767 for those very servers - did
> you check with rpcinfo ?

On the client :
# rpcinfo -p 10.0.0.1
   program no_version protocole  no_port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32765  status
    100024    1   tcp  32765  status
    100011    1   udp  32769  rquotad
    100011    2   udp  32769  rquotad
    100011    1   tcp  32769  rquotad
    100011    2   tcp  32769  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100021    1   udp  57059  nlockmgr
    100021    3   udp  57059  nlockmgr
    100021    4   udp  57059  nlockmgr
    100021    1   tcp  32768  nlockmgr
    100021    3   tcp  32768  nlockmgr
    100021    4   tcp  32768  nlockmgr
    100005    1   udp  32767  mountd
    100005    1   tcp  32767  mountd
    100005    2   udp  32767  mountd
    100005    2   tcp  32767  mountd
    100005    3   udp  32767  mountd
    100005    3   tcp  32767  mountd


On the nfs server :
#cat /etc/sysconfig/nfs
STATD_PORT=32765
STATD_OUTGOING_PORT=32766
MOUNTD_PORT=32767
LOCKD_TCPPORT=32768
RQUOTAD_PORT=32769

I have the problem on 2 computers. One is in the same network and is not
firewalled. I tried to mount the nfs (without ssh tunnel), and it works.
The problem appears only when i try to make the encapsulation.

(I don't know if my problem is best for nfs mailing-list or ssh mailing
list.)

Oudoubah


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
