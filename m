From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Wed, 25 Apr 2007 15:42:14 +0100
Message-ID: <20070425144214.GB6217@infradead.org>
References: <17958.48121.280256.493824@notabene.brown>
	<20070425095826.GA25349@infradead.org>
	<462F55FE.5020502@RedHat.com>
	<200704251610.39864.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Aime.Le-Rouzic@bull.net, Neil Brown <neilb@suse.de>,
	Steve Dickson <SteveD@redhat.com>,
	Christoph Hellwig <hch@infradead.org>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>, anibal@debian.org
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgihE-0005r5-6s
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 07:42:16 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgihE-0007DY-In
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 07:42:18 -0700
In-Reply-To: <200704251610.39864.olaf.kirch@oracle.com>
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

On Wed, Apr 25, 2007 at 04:10:37PM +0200, Olaf Kirch wrote:
> Whatever we do, there needs to be some coordination with
> the glibc folks. If they don't accept any patches to the sunrpc
> code in their code base, then we need to talk about a way
> of transitioning that code out of there.

Yes.

> Isn't there a way to frob symbols so that the loader finds them
> while hiding them from the linker?

The only way to hide symbols seems to adding a new version symbol
of the same name ontop of it.  Which actually might make some sense
here by making the new versions stubs while preserving ABI compatiblity
for any old binary around.  But I suspect third parties would still
get very upset about this compile-time breakage.

Another alternative would be to not mess with the symbols in glibc
at all but use linker magic to emit a warning that people should use
librpc instead, similar to how linking any application using getc
against glibc will get you a warning that it's dangerous and should
not be used.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
