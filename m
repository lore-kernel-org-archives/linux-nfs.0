From: Olaf Kirch <okir@suse.de>
Subject: Re: RFC: mount.nfs
Date: Fri, 27 Aug 2004 20:24:53 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040827182452.GA20962@suse.de>
References: <20040827141529.GF23324@suse.de> <1093630421.5758.42.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0lPF-0002ek-JP
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 11:24:57 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C0lPD-0003t1-Vr
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 11:24:57 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1093630421.5758.42.camel@lade.trondhjem.org>
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

On Fri, Aug 27, 2004 at 02:13:42PM -0400, Trond Myklebust wrote:
> Note though that pmap_getmaps() is not supported on legacy portmappers
> (I think someone complained that their AIX system broke). This is why

In what way do these legacy portmappers fail? Does the PMAP_DUMP actually
kill the portmapper? If we are able to safely identify broken portmappers,
I assume we can fall back to enumerating the available versions by
sending a GETPORT request with version 0, and loop over that range.

I can easily put all that stuff into a library, no problem.

> the rewrite that is in Fedora Core 2 goes to such lengths to actually
> "ping" the server.

I wasn't aware that Redhat already had a rewrite. I'll take a look.

> Also note that ideally, we want to make stuff like this as part of a
> backend library, then have 3 different programs:
>   mount.nfs2
>   mount.nfs3
>   mount.nfs4
> that can be called when the user does
> 
>     mount -t nfs -onfsvers=%d

That's fine with me. But I think we still need a mount.nfs, because
we need to handle the case where the user doesn't specify an NFS
version. Calling all mount.nfsX apps in turn may be a bit awkward.

> The reason why I want to split out nfs2 from the nfs3 mount is that at
> some point in the near future, I'd like to change the filesystem
> registration to create 'struct file_system_type' entries for NFSv2 and
> NFSv3. That will enable us to
> 
>    a) clean up the struct nfs_mount to get rid of all that "struct
> socket", version 1 legacy crap

We can do that now, if we drop the requirement of making the struct
backward compatible. We already deduce the kernel API version by
looking at the kernel release number, so that can be done safely.

>    b) be able to enumerate exactly which NFS versions the kernel has
> been compiled to support by using 'cat /proc/filesystems'.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
