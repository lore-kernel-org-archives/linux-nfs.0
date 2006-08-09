From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: connectathon special test failure in recent kernels
Date: Tue, 8 Aug 2006 22:59:23 -0400
Message-ID: <76bd70e30608081959g6a76d7bcr1d78323630462f7c@mail.gmail.com>
References: <76bd70e30608081220q75c6c0f2v18e5ebb309b1c201@mail.gmail.com>
	<1155079971.5731.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAeI2-0007uw-Nz
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 19:59:26 -0700
Received: from nf-out-0910.google.com ([64.233.182.185])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAeI2-0006SN-1j
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 19:59:27 -0700
Received: by nf-out-0910.google.com with SMTP id a27so426189nfc
	for <nfs@lists.sourceforge.net>; Tue, 08 Aug 2006 19:59:23 -0700 (PDT)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <1155079971.5731.22.camel@localhost>
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

On 8/8/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Tue, 2006-08-08 at 15:20 -0400, Chuck Lever wrote:
> > Is the connectathon holey test failure going to be fixed before 2.6.18
> > is finalized?
>
> Depends. Have you traced it in order to figure out what is wrong?

Ah.  Bruce reported this problem a while back, and said that it goes
away if one of your recent patches to fs/nfs/read.c is reverted.
Bruce?

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
