From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Wed, 25 Apr 2007 09:22:06 -0400
Message-ID: <462F55FE.5020502@RedHat.com>
References: <17958.48121.280256.493824@notabene.brown>
	<20070424171708.GA7936@infradead.org> <462E43CC.6040806@RedHat.com>
	<200704251056.03664.olaf.kirch@oracle.com>
	<20070425095826.GA25349@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Aime.Le-Rouzic@bull.net, Neil Brown <neilb@suse.de>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>,
	Olaf Kirch <olaf.kirch@oracle.com>, anibal@debian.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HghRr-0003Xv-CM
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 06:22:19 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HghRs-0004nZ-Kn
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 06:22:21 -0700
In-Reply-To: <20070425095826.GA25349@infradead.org>
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
> On Wed, Apr 25, 2007 at 10:56:01AM +0200, Olaf Kirch wrote:
>> I'm wondering whether all that hassle is really worth
>> it. There should be a way to IPv6 enable the glibc RPC
>> implementation without having to go to TIRPC. Yes,
>> Solaris requires rpcbind and such in order to do IPv6.
>> But that's not the same as replacing glibc's sunrpc code.
> 
> Yepp.  One other thing about tirpc is that it pulls in a lot
> of TLI crap.  Given that we never implemented TLI on Linux
> and never will this seems like a lot of useless baggae.
> 
> (Especially as SUN is backing down a lot on TLI aswell)
I really don't have any idea what SUN is or is not doing,
and sure it *might* be possible to simply turn IPv6 in the
glibc RPC code but its been stated very clearly that will
not happen because the glibc people no longer want to
support that code... They have and will continue to
resit any and all changes...

So all I'm trying to is instead of beating our heads against
the glibc wall, I simply trying to go around it with an
alternative solution and the libtirpc library seems like
it would be a good alternative...

Are there any other alternatives out there???

steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
