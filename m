From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 0/3] NLM lock failover
Date: Sat, 05 Aug 2006 01:44:42 -0400
Message-ID: <1154756682.3384.34.camel@localhost.localdomain>
References: <44A41246.2070106@redhat.com>
	<1154397341.3378.10.camel@localhost.localdomain>
	<1154683665.21040.2431.camel@hole.melbourne.sgi.com>
	<1154698079.3378.2.camel@localhost.localdomain>
	<1154703362.3378.45.camel@localhost.localdomain>
	<1154706709.4727.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Eme-0004k0-JH
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 22:33:12 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G9Eme-0005xN-Of
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 22:33:13 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1154706709.4727.21.camel@localhost>
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

On Fri, 2006-08-04 at 11:51 -0400, Trond Myklebust wrote:
> On Fri, 2006-08-04 at 10:56 -0400, Wendy Cheng wrote:
> > Anyway, better be conservative than sorry - I think we want to switch to
> > "fsid" approach to avoid messing with these networking issues, including
> > IPV6 modification. That is, we use fsid as the key to drop the lock and
> > set per-fsid NLM grace period. The ha-callout will have a 4th argument
> > (fsid) when invoked. 
> 
> What is the point of doing that? As far as the client is concerned, a
> server has either rebooted or it hasn't. It doesn't know about single
> filesystems rebooting.
> 

For active-active failover, the submitted patches allow:  

1: Drop the locks tied with one particular floating ip (in old server).
2: Notify relevant clients that the floating ip has been rebooted.
3: Set per-ip nlm grace period.
4: The (notified) nfs clients reclaim locks into the new server.

While the above 4 steps are being executed, both servers keep alive with
other nfs services un-interrupted. (1) and (3) are accomplished by Patch
3-1 and Patch 3-2. (4) is nfs client's task that follows its existing
logic without changes. 

For (2), the basics are built upon the existing rpc.statd's HA features,
specifically the -H and -nNP option. It, however, needs Patch 3-3 to
pass the correct floating ip address into rpc.statd user mode daemon as
the following: 

For system not involved in HA failover, nothing has change. All new
functions are optional with added-on feature. For cluster failover,

1. The rpc.statd is dispatched as "rpc.statd -H ha-callout"
2. Upon each monitor RPC calls (SM_MON or SM_UNMON), rpc.statd
   received the following from kernel:
   2-a: event (mon or unmon)
   2-b: server interface
   2-c: client interface.
3. The rpc.statd does its normal chores by writing or deleting 
   the client interface to/from the default sm directory. Server
   interface is not used here.  
   (btw, this is the existing logic without changes).
4. Then, the rpc.statd invokes ha-callout with the following three
   arguments:
   4-a: event (add-client or del-client)
   4-b: server interface
   4-c: client interface
   The ha-callout (in our case, it will be part of RHCS cluster suite)
   builds multiple sm directories based on 4-b, say 
   /shared_storage/sm_x,  where x is server's ip interface.
5. Upon failover, the cluster suite invokes 
   "rpc.statd -n x -N -P /shared_storage/sm_x" to notify affected
   clients. The new short-life rpc.statd will send the notification to
   relevant (nlm) clients and subsequently exits. The old rpc.statd
   (from step 1) is not aware of the failover event.

Note that before patch 3-3, the kernel always sets 2-b to
system_utsname.nodename. For rpc.statd, if RESTRICTED_STATD flag is on,
the rpc.statd always set 4-b to 127.0.0.1. Without RESTRICTED_STATD on,
it sets 4-b with whatever was passed by kernel (via 2-b). What (kernel)
patch 3-3 does is setting 2-b to the floating ip so rpc.statd could get
the correct ip and pass it into 4-b.

Greg said (I havn't figured out how) without setting 4-b to 127.0.0.1,
we "may" open a security hole. So the thinking here is, then, let's not
change anything but add an fsid as 4th argument for ha-callout as:

   4-d: fsid.

where "fsid" can be viewed as an unique identifier for an NFS export
specified in exports file (check "man exports"); e.g.

        /failover_dir   *(rw, fsid=1234)

With the added fsid info from ha-callout program, the cluster suite (or
human administrator) should be able to associated which (nlm) client has
been affected by one particular failover. 

>From implementation point of view, since fsid, if specified, has already
been part of the filehandle that is part of the nlm_file structure, we
should be able to replace the floating ip in the submitted patches with
fsid and still accomplish the very same thing. In short, the failover
sequence with the new interface would look like:

taken-over server:
A-1. tear down floating ip, say 10.10.1.1
A-2. unexport subject filesystem
A-3. "echo 1234 > /proc/fs/nfsd/nlm_unlock"  //fsid=1234
A-4. umount filesystem.

take-over server:
B-1. mount the subject filesystem
B-2. "echo 1234 > /proc/fs/nfsd/nlm_set_ip_grace"
B-3. "rpc.statd -n 10.10.1.1 -N -P /shared_storage/sm_10.10.1.1"
B-4. bring up 10.10.1.1
B-5. re-export the filesystem

A-3 and B-2 could be issued multiple times if the floating ip is
associated with multiple fsid(s).

Make sense ?

This fsid can also resolve Neil's concern (about nlm client using wrong
server interface to access filesystem) that I'll follow up sometime next
week. 

-- Wendy





-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
