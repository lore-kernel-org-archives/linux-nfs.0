From: Peter Staubach <staubach@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Tue, 24 Apr 2007 16:36:36 -0400
Message-ID: <462E6A54.1010709@redhat.com>
References: <17958.48121.280256.493824@notabene.brown>	<462CB496.6000308@RedHat.com>	<17965.15503.703515.820793@notabene.brown>	<200704240908.39672.olaf.kirch@oracle.com>	<20070424161027.GA30213@infradead.org>	<462E38B9.5020808@RedHat.com>
	<20070424171708.GA7936@infradead.org>	<462E43CC.6040806@RedHat.com>	<Pine.LNX.4.64.0704242053510.32688@maggie.lkpg.cendio.se>
	<462E6812.6040401@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: =?ISO-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>,
	nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgRkn-00072w-Lo
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 13:38:07 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgRkq-00033T-0q
	for nfs@lists.sourceforge.net; Tue, 24 Apr 2007 13:36:52 -0700
In-Reply-To: <462E6812.6040401@RedHat.com>
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

Steve Dickson wrote:
> Peter =C5strand wrote:
>   =

>> One thing that bothers me is that the current libtirpc[*] is different =

>> from other TI-RPC versions. The current version (as far as I understand) =

>> is based on a snapshot from FreeBSD, which is turn is based on Suns TIRP=
C =

>> 2.3. This code is *not* up to date with TI-RPC 2.9 (aka tirpcsrc_99) and =

>> certainly not with the latest OpenSolaris version.
>>     =

> hmm... Were does one go to find out how to be come tirpcsrc_99
> compliant and why is this important? Does the TI-RPC 2.9
> use a different over-the-wire protocol? I surely hope not... :-\
>
>   =


The chance that Sun actually changed any of the interfaces from one
version of TIRPC to the next is virtually nil.  Compatibility is a
huge thing to them.  Any changes would most likely have been made
in a backwards compatible fashion.


And no, there are no differences in the over the wire protocol.

>> Getting Linux distributions to ship (the same) version of TI-RPC is a =

>> worthwhile goal, but ideally, we should have an upstream project that =

>> covers not only Linux, but also, *BSD, OpenSolaris etc. I know it's not =

>> going to be easy, but I think it's worth a try.
>>     =

> Well if we having support thats needed and/or wanted it should not
> be too difficult to get people to move over...

Having such a project would be a good thing.  We would need developers
for each release platform targeted though.  Perhaps it might be sufficient
to start with platforms that we are interested in and as people with other
platforms become interested, they can port the support and add their own
patches to the central source base.

I don't think that I understand why being bug for bug compatible with
the current glibc code is interesting.  This is a new version of the
RPC support and applications will explicitly need to be ported to it.
Perhaps we could even pleasantly surprise some folks by addressing
some particular pet bug that they might have encountered.

    Thanx...

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
