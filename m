From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 0/3] NLM lock failover
Date: Mon, 07 Aug 2006 14:05:57 +1000
Message-ID: <1154923557.29877.106.camel@hole.melbourne.sgi.com>
References: <44A41246.2070106@redhat.com>
	<1154397341.3378.10.camel@localhost.localdomain>
	<1154683665.21040.2431.camel@hole.melbourne.sgi.com>
	<1154698079.3378.2.camel@localhost.localdomain>
	<1154703362.3378.45.camel@localhost.localdomain>
	<1154706709.4727.21.camel@localhost>
	<1154756682.3384.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9wNZ-00072r-GH
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 21:06:13 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G9wNZ-0000WR-Pt
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 21:06:14 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <1154756682.3384.34.camel@localhost.localdomain>
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

On Sat, 2006-08-05 at 15:44, Wendy Cheng wrote:
> On Fri, 2006-08-04 at 11:51 -0400, Trond Myklebust wrote:
> > On Fri, 2006-08-04 at 10:56 -0400, Wendy Cheng wrote:

> Note that before patch 3-3, the kernel always sets 2-b to
> system_utsname.nodename. For rpc.statd, if RESTRICTED_STATD flag is on,
> the rpc.statd always set 4-b to 127.0.0.1. Without RESTRICTED_STATD on,
> it sets 4-b with whatever was passed by kernel (via 2-b). What (kernel)
> patch 3-3 does is setting 2-b to the floating ip so rpc.statd could get
> the correct ip and pass it into 4-b.
> 
> Greg said (I havn't figured out how) without setting 4-b to 127.0.0.1,
> we "may" open a security hole.

Aha, I see what you needed.  You could have changed the logic
in the RESTRICTED_STATD case of sm_mon_1_svc() not to ignore the
passed my_addr.s_addr if svc_getcaller(rqstp->rq_xprt) is a
privileged port on localhost.  This would probably give you your
logic without reopening the security hole.

> take-over server:
> B-1. mount the subject filesystem
> B-2. "echo 1234 > /proc/fs/nfsd/nlm_set_ip_grace"
> B-3. "rpc.statd -n 10.10.1.1 -N -P /shared_storage/sm_10.10.1.1"
> B-4. bring up 10.10.1.1
> B-5. re-export the filesystem

Umm, don't you want to do B-3 after B-4 and B-5 ?  Otherwise
clients might racily fail on the first try.

Also, just curious here, when do you purge the clients' ARP caches?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
