From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: Another hang problem - Jukebox error (was: NFS hangs
	for15 seconds after exportfs -r)
Date: Wed, 18 Jan 2006 16:46:09 -0500
Message-ID: <1137620769.8706.47.camel@lade.trondhjem.org>
References: <C664ABFF405D6A458806C03AA2E0FF6B06CBC749@MKEMLVEM01.e2k.ad.ge.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EzL8P-0007pM-5M
	for nfs@lists.sourceforge.net; Wed, 18 Jan 2006 13:46:29 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EzL8N-00006P-5x
	for nfs@lists.sourceforge.net; Wed, 18 Jan 2006 13:46:29 -0800
To: "Edwards, Scott (GE Healthcare)" <J.Scott.Edwards@ge.com>
In-Reply-To: <C664ABFF405D6A458806C03AA2E0FF6B06CBC749@MKEMLVEM01.e2k.ad.ge.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wed, 2006-01-18 at 15:37 -0600, Edwards, Scott (GE Healthcare) wrote:
> Hi Trond,
> 
> It appears to me that ETIMEDOUT was the only one translated to JUKEBOX
> prior to 2.6.9, but this was added in 2.6.9:
> 
> msa8002@ox$ diff linux-2.6.9/fs/nfsd/nfsproc.c linux-2.6.8.1/fs/nfsd
> 589d588
> <               { nfserr_jukebox, -EWOULDBLOCK },
> msa8002@ox$ 

Sure? I checked out the today's GIT tree and all I get is

trondmy@lade nfsd$ grep -i jukebox *
nfs4state.c:                            status = nfserr_jukebox;
nfsproc.c:              { nfserr_jukebox, -ETIMEDOUT },
nfssvc.c:       if (nfserr == nfserr_jukebox && rqstp->rq_vers == 2)

vfs.c explicitly converts the EWOULDBLOCK it gets from break_lease into
an ETIMEDOUT, so that all other cases of EWOULDBLOCK == EAGAIN will be
returned as nfserr_dropit.

> I don't think we have samba on the machines at all and NFS4 shouldn't
> even be active.

OK. Is it only a specific operation that is returning NFS3ERR_JUKEBOX,
or are they all?

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
