From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Fri, 27 Apr 2007 15:17:10 +0100
Message-ID: <20070427141710.GA11484@infradead.org>
References: <17959.5245.635902.823441@notabene.brown>
	<462D79F0.4060800@redhat.com>
	<17965.39683.396108.623418@notabene.brown>
	<46302C01.2060500@redhat.com>
	<17968.15370.88587.653447@notabene.brown>
	<46315EED.9020103@redhat.com>
	<17969.37229.250000.895316@notabene.brown>
	<20070427111513.GA25126@salusa.poochiereds.net>
	<17969.61232.323762.29003@notabene.brown>
	<20070427134248.GB25126@salusa.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, cluster-devel@redhat.com,
	nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhRG4-0000Si-ES
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 07:17:12 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HhRG5-0005b8-Ph
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 07:17:15 -0700
In-Reply-To: <20070427134248.GB25126@salusa.poochiereds.net>
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

On Fri, Apr 27, 2007 at 09:42:48AM -0400, Jeff Layton wrote:
> Ok, I'll toss cleaning that patch up and reposting it on to my to-do list...
> 
> Wendy, it seems like you had some objection to this patch at the time, but
> the nature of it escapes me. Do you recall what your concern with it was?

I like the idea of the patch.  Intead of writing a dev_t into procfs
it should probably be changed to write a path to a new file in the
nfsctl filesystem.   In fact couldn't this be treated as a reexport
with a NFSEXP_ flag meaning drop all locks to avoid creating new
interfaces?


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
