From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Tue, 24 Apr 2007 13:52:12 -0400
Message-ID: <462E43CC.6040806@RedHat.com>
References: <17958.48121.280256.493824@notabene.brown>
	<462CB496.6000308@RedHat.com>
	<17965.15503.703515.820793@notabene.brown>
	<200704240908.39672.olaf.kirch@oracle.com>
	<20070424161027.GA30213@infradead.org>
	<462E38B9.5020808@RedHat.com> <20070424171708.GA7936@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Matthias Koenig <mkoenig@novell.com>,
	nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>,
	Olaf Kirch <olaf.kirch@oracle.com>, anibal@debian.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgPW7-0002BX-Eo
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 11:13:31 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgPW9-0003BB-Q2
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 11:13:34 -0700
In-Reply-To: <20070424171708.GA7936@infradead.org>
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



Christoph Hellwig wrote:
>> Secondly, having the to debug and fix a small part of the
>> RPC code in glibc, I have experienced how truly difficult
>> it is work with such a large beast... so I pretty confident
>> that breaking out the RPC into a library we can maintain
>> ourselves is a good direction to move...
> 
> Well, even with a separate library it's probably better to
> start out with the glibc code to bug to bug compatible.
In theory yes...  but unfortunately Transport Independent
RPC code is much different than the RPC we have in glibc.
The TI-RPC code deals with things like CLTS and COTS and
has configuration file that defines how theses CLITS/COTS
are handled... notions that are completely foreign to
the current RPC code...

Again, I realize this code is very raw, but the only way
to bring it up to speed (something I really thing we want
to do) is using it and making it available to the community.

steved.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
