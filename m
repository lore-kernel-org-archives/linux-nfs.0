From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: cel's patches for 2.6.18 kernels
Date: Thu, 21 Sep 2006 13:41:22 -0400
Message-ID: <1158860482.5441.53.camel@lade.trondhjem.org>
References: <76bd70e30609201128r9188a17i51b779c6e1b569fc@mail.gmail.com>
	<76bd70e30609201353l7d8c063fp94916c509b08b24e@mail.gmail.com>
	<1158787006.5639.19.camel@lade.trondhjem.org>
	<76bd70e30609201929s1e01b453ia694774d77f9474c@mail.gmail.com>
	<451284E4.4050806@RedHat.com>
	<1158846435.7626.7.camel@lade.trondhjem.org>
	<76bd70e30609210750s5c8b943cg267513c64dc0433f@mail.gmail.com>
	<1158851176.5441.17.camel@lade.trondhjem.org>
	<76bd70e30609210851h71b48c28ka2b283bd5842afd5@mail.gmail.com>
	<1158859983.5441.48.camel@lade.trondhjem.org>
	<76bd70e30609211037x73c0923avbcfaee20355a8f11@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GQSYL-0006Mr-5c
	for nfs@lists.sourceforge.net; Thu, 21 Sep 2006 10:41:37 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GQSYL-0001Bb-Gg
	for nfs@lists.sourceforge.net; Thu, 21 Sep 2006 10:41:38 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30609211037x73c0923avbcfaee20355a8f11@mail.gmail.com>
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

On Thu, 2006-09-21 at 13:37 -0400, Chuck Lever wrote:
> On 9/21/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > On Thu, 2006-09-21 at 11:51 -0400, Chuck Lever wrote:
> > > > There is already a mechanism in place for allowing the user to fiddle
> > > > with the limits,
> > >
> > > Why should any user care about setting this limit?  The client should
> > > be able to regulate itself to make optimal use of the available
> > > resources.  Hand-tuning this limit is simply a work around.
> >
> > Remind me why _you_ lobbied for the ability to do this?
> 
> Because currently it is the only way you will accept to make any
> adjustment at all.  It was a compromise.

...and it is one we are going to live with until you can prove to me
that these changes are safe.

As for your assertion that RTP has shown that 128 slots gives better
performance, that is good and fine, but does nothing to convince me that
these new patches are any improvement over what we already have.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
