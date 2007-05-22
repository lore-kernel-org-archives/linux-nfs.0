From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: Re: how to execute a script from NFS mount
	(which	disconnected)?
Date: Tue, 22 May 2007 14:17:49 +0200
Message-ID: <4652DF6D.8020209@wpkg.org>
References: <4652C7ED.9010309@wpkg.org>
	<1179835810.6501.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqTJV-0007k4-Sz
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 05:18:06 -0700
Received: from mail.syneticon.net ([213.239.212.131] helo=mail2.syneticon.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqTJW-0001fV-FG
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 05:18:08 -0700
In-Reply-To: <1179835810.6501.8.camel@heimdal.trondhjem.org>
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

Trond Myklebust schrieb:
> On Tue, 2007-05-22 at 12:37 +0200, Tomasz Chmielewski wrote:
>> How can I execute a script from NSF mount - a script which reconfigures 
>> a network interface, and there is a period of network disconnection?
> 
> Copy it to a RAMFS partition and execute it there.

No, that's not a good solution. Or a solution I would want to use.

I use the same script on systems having rootfs on iSCSI. And they also 
disconnect for a brief period of time.
There, everything works properly if I just "preload"/cache the 
script/programs with something like:

	cat script &>/dev/null
	program --help &>/dev/null

Then, I can disconnect the station for several minutes, but the system 
will have the programs/scripts cached, and will be able to use them.


I would like to do something similar with NFS. Isn't there a 
"disconnected" mode for NSF (or "cached", etc.)?


-- 
Tomasz Chmielewski
http://wpkg.org

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
