From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: cel's patches for 2.6.18 kernels
Date: Thu, 21 Sep 2006 13:33:18 -0400
Message-ID: <76bd70e30609211033k308eea00vd5cd113029449508@mail.gmail.com>
References: <76bd70e30609201128r9188a17i51b779c6e1b569fc@mail.gmail.com>
	<76bd70e30609201353l7d8c063fp94916c509b08b24e@mail.gmail.com>
	<1158787006.5639.19.camel@lade.trondhjem.org>
	<76bd70e30609201929s1e01b453ia694774d77f9474c@mail.gmail.com>
	<451284E4.4050806@RedHat.com>
	<1158846435.7626.7.camel@lade.trondhjem.org>
	<76bd70e30609210750s5c8b943cg267513c64dc0433f@mail.gmail.com>
	<1158851176.5441.17.camel@lade.trondhjem.org>
	<76bd70e30609210851h71b48c28ka2b283bd5842afd5@mail.gmail.com>
	<1158859317.5441.36.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GQSQN-0005c8-He
	for nfs@lists.sourceforge.net; Thu, 21 Sep 2006 10:33:23 -0700
Received: from wr-out-0506.google.com ([64.233.184.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GQSQM-0007gC-6Q
	for nfs@lists.sourceforge.net; Thu, 21 Sep 2006 10:33:24 -0700
Received: by wr-out-0506.google.com with SMTP id i20so390555wra
	for <nfs@lists.sourceforge.net>; Thu, 21 Sep 2006 10:33:18 -0700 (PDT)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1158859317.5441.36.camel@lade.trondhjem.org>
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

On 9/21/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Thu, 2006-09-21 at 11:51 -0400, Chuck Lever wrote:
> > On 9/21/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>
> > They are listed above.  See the paragraph that starts "The small slot
> > table size..."
>
> Supporting facts and figures, please.

Ask your colleagues in North Carolina.  They have unpublished numbers
to demonstrate that 128 slots improves TPC-C significantly over 32, or
even 64 slots.

And you know very well that the client will dump a lot of writes onto
the wire at once, via nfs_writepages.  If the server can handle them,
then the workload will move forward more quickly.  This kind of burst
is typical of intensive write workloads, and the burst of writes will
block other traffic on the transport if there are only a few slots
available.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
