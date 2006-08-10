From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: rpc.idmapd oops with latest NFS bits from your web site
Date: Thu, 10 Aug 2006 15:51:26 -0400
Message-ID: <76bd70e30608101251y60eb0f4bs4d458092f69ecf8b@mail.gmail.com>
References: <76bd70e30608101221se9d6fb6l8bb50e93109c7a5b@mail.gmail.com>
	<20060810195026.GA29260@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GBGZ0-0000XA-QG
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 12:51:31 -0700
Received: from nf-out-0910.google.com ([64.233.182.185])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GBGZ1-00030A-4S
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 12:51:31 -0700
Received: by nf-out-0910.google.com with SMTP id a27so636784nfc
	for <nfs@lists.sourceforge.net>; Thu, 10 Aug 2006 12:51:26 -0700 (PDT)
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20060810195026.GA29260@fieldses.org>
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

On 8/10/06, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Aug 10, 2006 at 03:21:41PM -0400, Chuck Lever wrote:
> > I ran connectathon basic tests 20 times against a Linux NFSv3 server.
> > At the end of the test I got this oops.  This is repeatable, but not
> > 100% of the time.
>
> The oops is from the client?

Yessir.

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
