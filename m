From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Wed, 25 Apr 2007 16:10:37 +0200
Message-ID: <200704251610.39864.olaf.kirch@oracle.com>
References: <17958.48121.280256.493824@notabene.brown>
	<20070425095826.GA25349@infradead.org>
	<462F55FE.5020502@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Aime.Le-Rouzic@bull.net, Neil Brown <neilb@suse.de>,
	Steve Dickson <SteveD@redhat.com>,
	Christoph Hellwig <hch@infradead.org>,
	Matthias Koenig <mkoenig@novell.com>,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>, anibal@debian.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgiE9-0001dQ-61
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 07:12:16 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HgiE9-0003U5-AP
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 07:12:15 -0700
In-Reply-To: <462F55FE.5020502@RedHat.com>
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

On Wednesday 25 April 2007 15:22, Steve Dickson wrote:
> Are there any other alternatives out there???

Whatever we do, there needs to be some coordination with
the glibc folks. If they don't accept any patches to the sunrpc
code in their code base, then we need to talk about a way
of transitioning that code out of there.

Isn't there a way to frob symbols so that the loader finds them
while hiding them from the linker? That would allow us to link
apps against a new librpc without risk of pulling in symbols from
glibc, and at the same time maintain binary compatibility in glibc
runtime. I'm not enough of a toolchain person, but I think stuff like
that is done routinely.

With that in place, you can decide whether it's easier to
go to libtirpc and pull in any missing pieces from glibc, or
whether it's better to start with a copy of the glibc code,
put it into git somewhere and evolve it from there. I think the
latter approach makes more sense. Gradual transisitons are
always preferrable.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
