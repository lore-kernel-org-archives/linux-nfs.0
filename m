From: Neil Brown <neilb@suse.de>
Subject: Re: Delays on "first" access to a NFS mount
Date: Thu, 8 Mar 2007 09:48:20 +1100
Message-ID: <17903.16692.884318.142587@notabene.brown>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
	<20070307224054.b2cbc294.simon.peter@gmx.de>
	<17903.14864.866148.254685@notabene.brown>
	<EXNANE01okLQ8aZRhQd00000077@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP4vs-0007ur-3g
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 14:48:28 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HP4vt-0007u8-O7
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 14:48:30 -0800
In-Reply-To: message from Talpey, Thomas on Wednesday March 7
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

On Wednesday March 7, Thomas.Talpey@netapp.com wrote:
> At 05:17 PM 3/7/2007, Neil Brown wrote:
> >On Wednesday March 7, simon.peter@gmx.de wrote:
> >> 
> >> I think what Tom had in mind was to stat all directories once, remember
> >> their values, have inotify keep an eye on 'em and whenever they change,
> >> update the remembered values. This way, disk access would only have to
> >> be done whenever something changes, which is when the disk is spun up
> >> anyway.
> >
> >There is certainly some sense in that approach.  I don't think
> >inotify is needed though.  The only part of the stat information we
> >are interested in is major/minor/inode numbers, and they don't change.
> 
> Actually I thought it would important to also look at the permission
> bits and/or any acls, in case access were revoked e.g mode 0. The
> export needs to be invalidated, basically as mountd would have found
> if exporting from scratch. Wouldn't it?

No.  The mode/acl on anything isn't interesting to mountd.  If the
client has access to a file, it gets access, if not: not.  That is all
handled by nfsd.
And remember that if you "chmod 0" a directory, that doesn't remove
access from people with files in the directory already open.


> 
> Come to think of it, maybe not. If the export goes bad then the
> client gets ESTALE, that's different from revoking access or never
> exporting. In that case I think mountd just needs to be sure the
> export point doesn't go away due to unmount, or is covered by a
> new one.

Mounting on top of an export point is an odd case that is not
explicitly handled.  Currently if you do that, the clients won't
notice until after 32 minutes of inactivity.
I'm not sure it is a case that is worth any effort to deal with
'sensibly'.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
