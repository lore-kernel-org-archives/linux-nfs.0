From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS file .lock problem?
Date: Fri, 05 Jan 2007 13:10:40 +0100
Message-ID: <1167999040.6050.30.camel@lade.trondhjem.org>
References: <20070104181136.M28899@quicknet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2nuY-00014n-GG
	for nfs@lists.sourceforge.net; Fri, 05 Jan 2007 04:11:02 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+/mvw92qcnIJGbmGmLfK3+NFDRNYrHee0=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H2nuY-00027G-Lg
	for nfs@lists.sourceforge.net; Fri, 05 Jan 2007 04:11:04 -0800
To: Ingmar <i2a@gmx.net>
In-Reply-To: <20070104181136.M28899@quicknet.nl>
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

On Thu, 2007-01-04 at 19:25 +0100, Ingmar wrote:
> Hi All,
> 
> I am having a problem with the Openoffice.org suite and am guessing it has something to do
> with NFS.
> 
> I am using NFS to mount my home dir, and Writer it will hang as soon as you (for example)
> remove the ruler check from the document interface.
> 
> When using another account with an local/"on disk" home dir there is no problem.
> 
> Something similar occurs with aMule, it is unable to write a lock file.
> 
> Are there any special options needed by NFS to export or mount the directory.

Are you running rpc.statd on both machines? Are there any
firewalls/netfilters that might get in the way of the NLM and NSM
protocols?

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
