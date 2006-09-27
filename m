From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: client write ordering
Date: Wed, 27 Sep 2006 15:25:20 -0400
Message-ID: <1159385120.5883.40.camel@lade.trondhjem.org>
References: <3A8D2969972400448F9C908CFE890D9503A34786@exchange1.DataDomain.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSf2J-0002Oe-ET
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 12:25:39 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GSf2J-00012r-05
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 12:25:40 -0700
To: Bob Fozard <Bob.Fozard@datadomain.com>
In-Reply-To: <3A8D2969972400448F9C908CFE890D9503A34786@exchange1.DataDomain.com>
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

On Wed, 2006-09-27 at 12:18 -0700, Bob Fozard wrote:
> Trond,
> 
> I very much appreciate your responses.  While I will experiment with
> /proc/sys/vm/dirty_ratio to understand its effects, what I see as the
> issue here is not so much _when_ the client decides to start flushing,
> but _how_ it goes about flushing.  Do you have some idea as to how the
> vm sorts pages for flushing?  Is it intended to mimic the order in which
> the application wrote them to any extent?  Surely its not random, but
> clearly it can take large jumps from time to time.  Even a simple LRU
> algorithm would give desirable behavior.

The NFS client will scan through the dirty pages linearly by page
offset, but will skip pages that are busy (i.e. that are being flushed
through some other mechanism, or that are in the process of being
updated).

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
