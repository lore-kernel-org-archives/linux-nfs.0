From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2/5] NLM failover - per fs grace period
Date: Mon, 14 Aug 2006 11:44:41 -0400
Message-ID: <1155570281.5664.84.camel@localhost>
References: <1155535221.3416.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCecz-0006e1-6E
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 08:45:21 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GCecy-0004Go-8J
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 08:45:21 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <1155535221.3416.26.camel@localhost.localdomain>
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

On Mon, 2006-08-14 at 02:00 -0400, Wendy Cheng wrote:
> This change enables per NFS-export entry lockd grace period. The
> implementation is based on a global single linked list nlm_servs that
> contains entries of fsid info. It is expected this would not be a
> frequent event. The nlm_servs list should be short and the entries
> expire within a maximum of 50 seconds.  The grace period setting follows
> the existing NLM grace period handling logic and is triggered via
> echoing the NFS export filesystem id into /proc/fs/nfsd/nlm_set_igrace
> file as:
> 
> shell> echo 1234 > /proc/fs/nfsd/nlm_set_igrace

I still don't find the above interface convincing.

Firstly, as I already told you, the NSM protocol does not allow you to
set only a single filesystem in grace. Clients get notified of server
reboots, not filesystem reboots: if they try to reclaim locks and find
out that some of filesystems they have mounted will not allow them to do
so, then they _will_ get confused and start dropping locks that would
otherwise be perfectly valid.

Secondly, with the above interface, you have to export the filesystem
first, and then set the grace period. Since that is not an atomic
operation, it is perfectly possible for someone to mount the filesystem,
after you exported it, then set a new lock before you have managed to
declare it in grace. This makes reclaiming locks impossible.

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
