From: Jeff Layton <jlayton@redhat.com>
Subject: Re: how to execute a script from NFS mount (which
 disconnected)?
Date: Tue, 22 May 2007 08:25:54 -0400
Message-ID: <20070522082554.b7e112d7.jlayton@redhat.com>
References: <4652C7ED.9010309@wpkg.org>
	<1179835810.6501.8.camel@heimdal.trondhjem.org>
	<4652DF6D.8020209@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqTRC-0008TM-6W
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 05:26:02 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqTRE-0003n6-Q9
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 05:26:05 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l4MCPt22009301
	for <nfs@lists.sourceforge.net>; Tue, 22 May 2007 08:25:55 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l4MCPt8t020985
	for <nfs@lists.sourceforge.net>; Tue, 22 May 2007 08:25:55 -0400
Received: from tleilax.poochiereds.net (vpn-14-89.rdu.redhat.com [10.11.14.89])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with SMTP id l4MCPs2p001380
	for <nfs@lists.sourceforge.net>; Tue, 22 May 2007 08:25:54 -0400
In-Reply-To: <4652DF6D.8020209@wpkg.org>
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

On Tue, 22 May 2007 14:17:49 +0200
Tomasz Chmielewski <mangoo@wpkg.org> wrote:

> Trond Myklebust schrieb:
> > On Tue, 2007-05-22 at 12:37 +0200, Tomasz Chmielewski wrote:
> >> How can I execute a script from NSF mount - a script which reconfigures 
> >> a network interface, and there is a period of network disconnection?
> > 
> > Copy it to a RAMFS partition and execute it there.
> 
> No, that's not a good solution. Or a solution I would want to use.
> 
> I use the same script on systems having rootfs on iSCSI. And they also 
> disconnect for a brief period of time.
> There, everything works properly if I just "preload"/cache the 
> script/programs with something like:
> 
> 	cat script &>/dev/null
> 	program --help &>/dev/null
> 
> Then, I can disconnect the station for several minutes, but the system 
> will have the programs/scripts cached, and will be able to use them.
> 
> 
> I would like to do something similar with NFS. Isn't there a 
> "disconnected" mode for NSF (or "cached", etc.)?
> 

Nope. NFS will (likely) want to check the attributes on the file to make sure
it's not changed before executing it. Copying it to a secondary location is
what you'll want to do.

<idle speculation>
I wonder if you could do something like this on NFSv4 with delegations?
</idle speculation>

> 
> -- 
> Tomasz Chmielewski
> http://wpkg.org
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
