From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Wed, 25 Apr 2007 15:37:42 +0100
Message-ID: <20070425143742.GA6217@infradead.org>
References: <17958.48121.280256.493824@notabene.brown>
	<20070424171708.GA7936@infradead.org> <462E43CC.6040806@RedHat.com>
	<200704251056.03664.olaf.kirch@oracle.com>
	<20070425095826.GA25349@infradead.org>
	<462F55FE.5020502@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Aime.Le-Rouzic@bull.net, Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>,
	Olaf Kirch <olaf.kirch@oracle.com>, anibal@debian.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgidO-0005Ib-Q7
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 07:38:21 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgidQ-0006AI-6x
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 07:38:21 -0700
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

On Wed, Apr 25, 2007 at 09:22:06AM -0400, Steve Dickson wrote:
> and sure it *might* be possible to simply turn IPv6 in the
> glibc RPC code but its been stated very clearly that will
> not happen because the glibc people no longer want to
> support that code... They have and will continue to
> resit any and all changes...

I have the feeling we're talking past each other here :-)

Even if changes to glibc itself are not going to happen you still can
take the glibc rpc code, make changes to it and turn it into a
separate library.  Given the indicators that Ulrich doesn't want new
features in glibcs that seems to be the most useful solution.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
