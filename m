From: "Brian T" <btuch@usa.net>
Subject: Exporting an imported mount
Date: Tue, 6 Apr 2004 13:19:27 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <01aa01c41c03$b2e44340$fd0ba8c0@briantpc>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BAv6w-0008MT-7W
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 11:15:46 -0700
Received: from cmsrelay02.mx.net ([165.212.11.111])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1BAv6v-0006b1-QV
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 11:15:45 -0700
To: <nfs@lists.sourceforge.net>
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

Hi,

I didn't see this discussed in the archives, so my apologies if it has been
mentioned already.

I currently have a Fedora Core 1 server mounting a Novell drive with ncpfs,
and then attempting to export it so other Linux systems have mount it, but
am having no luck.  This used to work with my old Redhat 6.1 server.

When the Novell drive is not mounted, then Linux clients can mount the
server share, so I know NFS is working properly.  I see errors like this on
the server:

Apr  6 11:06:40 Zorak rpc.mountd: authenticated mount request from
192.168.10.200:755 for /mnt/jbmfs1 (/mnt/jbmfs1)
Apr  6 11:06:40 Zorak rpc.mountd: getfh failed: Operation not permitted

and on the client, I get a "permission denied" error.

So my main question, is it still possible to export an imported share, or
has that been removed due to licencing issues with Novell?

Thanks,

-Brian





-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
