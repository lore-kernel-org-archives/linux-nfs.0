From: Olaf Kirch <okir@suse.de>
Subject: Re: Linux NFS writes to Solaris very, very slow
Date: Fri, 23 Jul 2004 18:35:32 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040723163532.GA14157@suse.de>
References: <200407231620.i6NGKYV20945@algebra.hillsboro.credence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bo31E-0000kM-OM
	for nfs@lists.sourceforge.net; Fri, 23 Jul 2004 09:35:36 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Bo31E-0003fH-A3
	for nfs@lists.sourceforge.net; Fri, 23 Jul 2004 09:35:36 -0700
To: John Roberts <john_roberts@credence.com>
In-Reply-To: <200407231620.i6NGKYV20945@algebra.hillsboro.credence.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, Jul 23, 2004 at 09:20:34AM -0700, John Roberts wrote:
> What we've observed is that NFS writes from our Linux boxes to
> the Solaris server (and other Solaris workstations) is _very_
> slow.  Reads seem to be operating at a reasonable speed.
> FTP speeds are blazing (protocol below NFS).

What are your mount options? you should be using nfsv3; v2 is
of course terribly slow on writes.

> On a completely seperate note, Linux-to-Linux NFS file writes
> only seem to be fast if we publish the serving Linux volume
> as asynchronous (default setting is synchronous which is slow).

as long as your client uses nfsv2, that is to be expected. In
NFSv2 the (mandated) default is to use sync mode, i.e. write
each and every blob of data to disk before acknowledging the
RPC operation.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
