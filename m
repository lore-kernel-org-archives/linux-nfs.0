From: Bryan O'Sullivan <bos@serpentine.com>
Subject: Re: High Availability NFS Proposal
Date: 26 Aug 2002 12:41:56 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1030390916.2477.25.camel@plokta.s8.com>
References: <200208260451.g7Q4pM325746@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no,
	Robert Walsh <rjwalsh@durables.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from server.s8.com ([66.77.12.139])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jPkR-0006Io-00
	for <nfs@lists.sourceforge.net>; Mon, 26 Aug 2002 12:42:03 -0700
To: James Bottomley <James.Bottomley@steeleye.com>
In-Reply-To: <200208260451.g7Q4pM325746@localhost.localdomain>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Sun, 2002-08-25 at 21:51, James Bottomley wrote:

> Extra information for statd would pertain to virtual host, but by and large, 
> the information is identical.  Dnotify won't work because in order to close 
> race windows, the cluster has to be an active participant (i.e. mountd may not 
> reply until the cluster confirms it has the information), it can't just wait 
> on triggers.

Good point.  By the way, the race condition you describe is catastrophic
for at least one Linux NFS client.

I replicated the condition that a client would see as a result of the
race under 2.4.19 (with Trond's jumbo NFS patch) as follows:

        * Server exports an fs.
        * Client mounts it.
        * Server unexports it.
        * Client attempts to access the fs it thinks it still has
          mounted.

The client oopsed, and its VFS got completely wedged.  The client in
question was running headless (I wasn't expecting this operation to
cause a disaster), so I haven't captured the oops yet, but it was ...
more exciting than I expected.

I'll post a full report of the problem later, as time permits.

So yes, server-side hooks seem, er, somewhat important.

	<b


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
