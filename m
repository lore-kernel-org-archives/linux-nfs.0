From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: i insist! intermitent mount: RPC: Timed - please help
Date: Fri, 18 Jul 2003 11:26:57 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16151.19681.888795.782928@gargle.gargle.HOWL>
References: <1058397662.3190.2.camel@litio.futurahostdns.com>
	<1058490442.6067.7.camel@litio.futurahostdns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp3.unsw.edu.au ([149.171.96.70])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19dK1W-0007M6-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Jul 2003 18:27:02 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <support3@futurahost.com>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Fri, 18 Jul 2003 11:26:58 +1000
To: support3@futurahost.com
In-Reply-To: message from "FuturaHost.Com's "Support on  July 18
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

On  July 18, support3@futurahost.com wrote:
> 
> 	Im posting in the wrong list? Can someone in this list kindly make me
> note it and point me to the right one?

No, you are posting to the right list.  But there in not guarantee
that you will get a reply. People are busy etc.
When you don't get a reply, it doesn't hurt to send the question
again, so you have done the right thing!!

> >  [root@beryllium bin]# rpcinfo -p server
> >     program vers proto   port
> >      100000    2   tcp    111  portmapper
> >      100000    2   udp    111  portmapper
> >      100011    1   udp    770  rquotad
> >      100011    2   udp    770  rquotad
> >      100005    1   udp    778  mountd
> >      100005    1   tcp    781  mountd
> >      100005    2   udp    778  mountd
> >      100005    2   tcp    781  mountd
> >      100005    3   udp    778  mountd
> >      100005    3   tcp    781  mountd
> >      100003    2   udp   2049  nfs
> >      100003    3   udp   2049  nfs
> >      100021    1   udp  33829  nlockmgr
> >      100021    3   udp  33829  nlockmgr
> >      100021    4   udp  33829  nlockmgr

Hmm, you don't seem to be running 'statd', so locking won't work, but
that is not your immediate problem.

> >  [root@mars service]# rpcinfo -p
> >     program vers proto   port
> >      100000    2   tcp    111  portmapper
> >      100000    2   udp    111  portmapper
> >      100011    1   udp    770  rquotad
> >      100011    2   udp    770  rquotad
> >      100005    1   udp    778  mountd
> >      100005    1   tcp    781  mountd
> >      100005    2   udp    778  mountd
> >      100005    2   tcp    781  mountd
> >      100005    3   udp    778  mountd
> >      100005    3   tcp    781  mountd
> >      100003    2   udp   2049  nfs
> >      100003    3   udp   2049  nfs
> >      100021    1   udp  33829  nlockmgr
> >      100021    3   udp  33829  nlockmgr
> >      100021    4   udp  33829  nlockmgr

No statd on the server either.

> >  
> > 
> > 
> >  Here goes the funny part:
> >  [root@beryllium bin]# /bin/mount -t nfs -o,hard mars:/ /mnt/nfs
> >  mount: RPC: Timed out
> >  [root@beryllium bin]#

Any logs from mountd?  Maybe try 'strace' or 'ltrace' on mountd and
see what it is doing.

> >  
> >  But, when im trying to mount from the client, i see this in the server:
> >  
> >  [root@mars service]# netstat -alnp | grep :53
> >  udp        0      0 an.ip.onthe.server:34451  
> >  anip.on.the.server:53      
> >  ESTABLISHED 13781/rpc.mountd
> >  udp        0      0 anip.on.the.server:34453  
> >  anip.on.the.server:53      
> >  ESTABLISHED 13781/rpc.mountd
> >  
> >  udp        0      0 eth0.ip.on.server:34456  
> >  some.ip.querying.dnscache:53       
> >  ESTABLISHED 13781/rpc.mountd
> >  udp        0      0 eth0.ip.on.server:34457  
> >  a-dns.server.onresolv.conf:53            
> >  ESTABLISHED 13781/rpc.mountd
> >  
> > 
> >  It's like rpc.mountd is binding hiself on port 53.
> >  

But we know (from rpcinfo) that it isn't.
It is more like someone (mountd?) is doing a DNS request and maybe not
getting a reply.

My guess is that mountd gets the request from the client, does a DNS
lookup to verify the request, never gets an answer for some reason,
and so doesn't reply before the client times out.

I suggest checking that DNS lookup is really working on the server.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
