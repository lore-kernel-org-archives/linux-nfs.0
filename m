From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Wed, 25 Apr 2007 09:39:18 -0400
Message-ID: <462F5A06.4010200@RedHat.com>
References: <17958.48121.280256.493824@notabene.brown>
	<20070424171708.GA7936@infradead.org> <462E43CC.6040806@RedHat.com>
	<200704251056.03664.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Aime.Le-Rouzic@bull.net, Neil Brown <neilb@suse.de>,
	Aurelien.Charbon@ext.Bull.Net, Christoph Hellwig <hch@infradead.org>,
	Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Javier Fern?ndez-Sanguino Pe?a <jfs@computer.org>, anibal@debian.org
To: Olaf Kirch <olaf.kirch@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hghic-0005VL-FX
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 06:39:38 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hghie-0001tg-LI
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 06:39:41 -0700
In-Reply-To: <200704251056.03664.olaf.kirch@oracle.com>
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



Olaf Kirch wrote:
> On Tuesday 24 April 2007 19:52, Steve Dickson wrote:
>> In theory yes...  but unfortunately Transport Independent
>> RPC code is much different than the RPC we have in glibc.
> 
> Still, there's a whole load of shared code, and this is where
> I agree with Christoph that it would be foolish to throw away
> the work that went into the glibc code. 
Again I can't agree with you more... so lets port over that
"wisdom" into libtirpc...


> I stopped reading the code after an hour, but I think this list could
> be extended quite a bit.
Thanks for spending the time!!! I'll make sure each an every
one of these observations turning into a bug report...

> 
>> Again, I realize this code is very raw, but the only way
>> to bring it up to speed (something I really thing we want
>> to do) is using it and making it available to the community.
> 
> Well, there's one thing that makes the transition very tricky.
> I looked into this while I was still with Novell, because we had
> a request from the Bull folks to include tirpc. If you include
> tirpc, you either have to remove all RPC code from glibc
> at the same time, and fix up all applications linking against
> this code. Downside: no binary compatibility, and the customers
> who paid a lot of money for some commercial app will hate
> you if an OS upgrade requires them to buy new licenses.
Removing the RPC code from glibc is not an option. The
glibc people have made this very clear... So I see the
libtirpc library as an alternative to people that want
RPC over IPv6 support... and Yes they will have to recompile
to take advantage of this support... but I really don't think
that will be that big of a deal..

> 
> The other approach is to make sure that you provide *any*
> RPC related symbol glibc provides, in tirpc as well. Even
> if it does nothing, and just errors out. Otherwise you may end
> up with somebody's application linked against tirpc, but it
> calls some forgotten little function in glibc and falls over.
> This is tricky too.
Again... libtirpc is not replacing the glibc code. People
will have to explicitly link with the tirpc... Will there
be porting issues... yes... aren't there always?

steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
