From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Mon, 05 Mar 2007 16:37:58 -0500
Message-ID: <1173130678.6315.7.camel@heimdal.trondhjem.org>
References: <45EC7F0F.4090600@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOKsk-0004jM-6K
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 13:38:10 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOKsl-0007fX-48
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 13:38:12 -0800
In-Reply-To: <45EC7F0F.4090600@RedHat.com>
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

On Mon, 2007-03-05 at 15:35 -0500, Steve Dickson wrote:
> Over the last new months, I've been getting beaten up
> about the fact the Fedora Core clients (FC5 and FC6)
> no loner works with Tru64 server. The problem is
> accessing mounted directories would fail with -ENOTDIR.
> Similar to:
> 
> # ls /mnt/alpha/doc
> /bin/ls: cannot open directory /mnt/alpha/doc: Not a directory
> 
> After months of floundering around looking at ethereal
> traces and such, I actually was able to trace down a
> Tru64 server to test against (thanks you very much HP!).
> 
> Low and behold... it turns not to be a Linux client
> bug at all... but only Linux clients failed because
> they seem to actually care what fsids are being returned.
> 
> The problem is this: Tru64 server exporting Advfs fileystems
> return sign extend fsids in most but not all NFS procedures.
> 
> Meaning most fattrs returned by the server have a fsid of:
>      fsid: 0xffffffff8419f8d5
> 
> but in some procs (like READDIRPLUS) the fsid is
>      fsid: 0x000000008419f8d5
> 
> Which is _clearly_ wrong and does not happen with UFS
> exports on the same server.
> 
> So its my contention that Tru64 has been broken forever
> since only Linux clients fail, which started due to the
> following patch that went into 2.6.12:

Sorry, but I really do not like the idea of fixing server bugs in the
Linux client, and particularly not in generic code like this.

As far as I understood, this was a direct consequence of using the
32bitclients export option to work around the old issues with 64-bit
cookies on readdir. Is there really a need for this option now that
we've ensured that readdir cookies are no longer exported to userland?

Cheers
  Trond

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
