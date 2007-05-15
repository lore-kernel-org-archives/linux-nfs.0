From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Tue, 15 May 2007 10:33:42 -0400
Message-ID: <1179239622.6464.28.camel@heimdal.trondhjem.org>
References: <4627B3DD.5050409@amd.com>
	<1177007479.6623.14.camel@heimdal.trondhjem.org>	<4627D303.8060009@amd.com>
	<1177020662.6628.30.camel@heimdal.trondhjem.org>	<4627EBFC.2090704@amd.com>
	<462CFC92.2080201@amd.com> <463B97E6.4030009@amd.com>
	<1178314889.6533.19.camel@heimdal.trondhjem.org>
	<1178379473.4559.24.camel@raven.themaw.net>
	<1178385472.6561.43.camel@heimdal.trondhjem.org>
	<20070514131743.GG31764@petra.dvoda.cz>
	<1179149048.6858.5.camel@heimdal.trondhjem.org>
	<1179153555.3811.57.camel@raven.themaw.net>
	<1179157631.6474.8.camel@heimdal.trondhjem.org>
	<1179158812.3811.68.camel@raven.themaw.net>
	<17992.58783.827023.697258@notabene.brown>
	<1179184319.6467.7.camel@heimdal.trondhjem.org>
	<4649BC6F.2010906@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Paul Krizak <paul.krizak@amd.com>,
	nfs@lists.sourceforge.net, Ian Kent <raven@themaw.net>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hny68-0005hL-IJ
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 07:33:56 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hny6A-0003ki-At
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 07:33:59 -0700
In-Reply-To: <4649BC6F.2010906@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 2007-05-15 at 09:58 -0400, Chuck Lever wrote:

> Just kicking it out there: why not revert the kernel back to the 
> previous state of affairs where "nosharedcache" was the default, and 
> then let user space handle sharing or not sharing, documenting clearly 
> what the implications are in the mount(8) or nfs(5) man pages?  User 
> space is smart enough to emit a warning about mixing security flavors, 
> for instance, as suggested above.

Read the thread. See my previous answers.

Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
