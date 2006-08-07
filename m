From: James Yarbrough <jmy@sgi.com>
Subject: Re: [PATCH 0/3] NLM lock failover
Date: Mon, 07 Aug 2006 13:14:30 -0700
Message-ID: <44D79F26.B93E5C00@sgi.com>
References: <44A41246.2070106@redhat.com>
	<1154397341.3378.10.camel@localhost.localdomain>
	<1154683665.21040.2431.camel@hole.melbourne.sgi.com>
	<1154698079.3378.2.camel@localhost.localdomain>
	<1154703362.3378.45.camel@localhost.localdomain>
	<1154706709.4727.21.camel@localhost>
	<1154756682.3384.34.camel@localhost.localdomain>
	<1154923557.29877.106.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Wendy Cheng <wcheng@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GABUn-00067A-O7
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 13:14:41 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GABUl-0003mR-Qu
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 13:14:42 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
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

> > take-over server:
> > B-1. mount the subject filesystem
> > B-2. "echo 1234 > /proc/fs/nfsd/nlm_set_ip_grace"
> > B-3. "rpc.statd -n 10.10.1.1 -N -P /shared_storage/sm_10.10.1.1"
> > B-4. bring up 10.10.1.1
> > B-5. re-export the filesystem
> 
> Umm, don't you want to do B-3 after B-4 and B-5 ?  Otherwise
> clients might racily fail on the first try.

I don't think they will necessrily fail.  It depends on whether the
server sends ICMP unreachable messages and how the client responds to
those.  In any case, I think the ordering should be B-5, B-4, and B-3
last.  One can argue about the ordering of B-3 and B-4, but if exporting
(B-5) does not happen before bringing up the IP address (B-4), clients
can get ESTALE replies.  For better transparency, it's probably best
to avoid ESTALE.

It's probably OK to do step B-3 after bringing up the IP address since
that will mimic what happens during boot.

> 
> Also, just curious here, when do you purge the clients' ARP caches?

I don't think you can actually do a purge from the server explicitly.
You should get the desired result when the IP address (10.10.1.1 in
the above example) is brought up.  There's a gratuitous ARP that goes
with that step.

-- 
jmy@sgi.com
650 933 3124

Blow up the mailbox!

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
