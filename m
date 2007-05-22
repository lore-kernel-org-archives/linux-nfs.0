From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: how to execute a script from NFS
	mount	(which	disconnected)?
Date: Tue, 22 May 2007 08:41:51 -0400
Message-ID: <1179837711.6501.10.camel@heimdal.trondhjem.org>
References: <4652C7ED.9010309@wpkg.org>
	<1179835810.6501.8.camel@heimdal.trondhjem.org>
	<4652DF6D.8020209@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Tomasz Chmielewski <mangoo@wpkg.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqTgZ-0001b2-GB
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 05:41:55 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX192S1qHiutzv94ZDAQS3fOmTw0tAeZvqzg=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HqTgb-0007kJ-TM
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 05:41:58 -0700
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

On Tue, 2007-05-22 at 14:17 +0200, Tomasz Chmielewski wrote:
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

Feel free to write one. Otherwise, the only solution I can propose for
you is the one I just mentioned.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
