From: "Brandon D. Valentine" <brandon@dvalentine.com>
Subject: Re: [bug] FC2/2.6.8.1 does not fallback to NFSv2
Date: Sat, 28 Aug 2004 13:38:47 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040828183847.GA84014@brandon.dvalentine.com>
References: <20040827212244.GA57703@brandon.dvalentine.com> <1093642565.5758.108.camel@lade.trondhjem.org> <1093643490.5758.120.camel@lade.trondhjem.org> <20040827233235.GB57703@brandon.dvalentine.com> <4130BC76.9070202@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1889-0007sq-7A
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 11:40:49 -0700
Received: from mail.michaelchaney.com ([207.65.84.68] helo=daphne.michaelchaney.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C1887-000692-Jv
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 11:40:49 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4130BC76.9070202@RedHat.com>
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

On Sat, Aug 28, 2004 at 01:10:14PM -0400, Steve Dickson wrote:
> Upgrade your nfs-utils to the latest rawhide version
> (nfs-utils-1.0.6-31 I believe) to see if it take care of the problem.
> I think this has to do with the order of how mountd and rpc.imapd are
> started. Basically mountd has to be running before rpc.idmapd  for
> things to work...  So in  the case of the server (where rpc.idmapd is
> already started), the nfs startup script send rpc.idmapd a signal
> telling it to reopen its nfsd files (i.e. files under /proc/fs/nfsd )

I do not see how rpc.idmapd has anything at all to do with NFSv2/3, it
is an NFSv4ism.  Also, rpc.mountd on the server is working fine, as
evidenced by the rpcinfo output I included in a previous message and the
fact that every other client on the network mounts filesystems from it
successfully.

In other words: what the heck are you talking about? =)

Brandon D. Valentine
-- 
brandon@dvalentine.com                           http://www.geekpunk.net
Pseudo-Random Googlism:  sunshine is a great game that anyone will enjoy


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
