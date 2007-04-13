From: Lon Hohberger <lhh@redhat.com>
Subject: Re: [PATCH 3/4 Revised] NLM - kernel lockd-statd changes
Date: Fri, 13 Apr 2007 15:16:16 -0400
Message-ID: <20070413191615.GU1804@redhat.com>
References: <46156FA0.4030506@redhat.com> <200704101109.44333.okir@lst.de>
	<17948.26876.426822.963222@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcRFv-0002GT-Ee
	for nfs@lists.sourceforge.net; Fri, 13 Apr 2007 12:16:25 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HcRFw-0003MP-IN
	for nfs@lists.sourceforge.net; Fri, 13 Apr 2007 12:16:26 -0700
In-Reply-To: <17948.26876.426822.963222@notabene.brown>
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

On Wed, Apr 11, 2007 at 02:50:04PM +1000, Neil Brown wrote:
> Think of it like this.  The goal is (appears to be) to make it
> possible to implement multiple independent NFS servers on the one
> Linux host.
> As a simplification, each server serves precisely one filesystem which
> no other server serves, and each server has precisely one network
> address which no other server shares.

The simplification here is a bit incorrect; we need to be able to handle
a given *set* of size >= 1 IPs which is paired with a *set* of size >= 1
of fsids.  The sets are not broken up (that is, we won't be moving 
file systems between IP addresses or vice-vers), but the number of
IPs:filesystems need not be 1:1.

   * 1 file system, 1 ip address
   * 2 fs, 1 ip
   * 1 ip, 2 fs
   * 18 ip, 42 fs.

... should all work without extraneous stuff being done.


> lockd knows which is which either based on the destination network
> address of the lock request, or the filesystem on which the lock was
> taken.   Somehow this information needs to get communicated to statd
> so that different 'sm' directories can be used.  my_name seems a
> sensible place to put the information.

Right.  Using the inbound-destination address instead of fsid or file
system will ensure the right address is used for sending the SM_NOTIFY
requests.  However, fsid, or export path - on a service with more than
one network address will not, I think...

Obviously, I agree with Olaf in that using all sorts of random network
protocol addresses is a hair ugly - but I think it's better than having
to send out multiple SM_NOTIFY messages on multiple net addrs just to
ensure that a particular client gets SM_NOTIFY from the *right* net
addr that it had in its monitor list...

If we could have a single 'name' per service that can get associated
with multiple network addresses, I'm all for it.

Just my opinion, of course.

> However:  now that I think I actually understand what is happening, I
> wonder if FSID and IPaddress are really the right handles to use.  It
> would seem to make more sense to use the filesystem name (i.e. a
> path).

This doesn't solve the 2 ip : 1 fs case very cleanly.  We need to send
SM_NOTIFY out on multiple IPs to ensure that each node gets it from the
right server address (that the client has on its monitor list)...?

Really, the goal is to have:

  * clients receive SM_NOTIFY from the ("virtual") host(s) they are
    monitoring when we start the service
  * No extraneous SM_NOTIFY requests are sent by server.
  * No extraneous SM_NOTIFY requests are received by clients.

-- 
Lon Hohberger - Software Engineer - Red Hat, Inc.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
