From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Thu, 6 May 2004 18:24:55 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040506222455.GP18964@fieldses.org>
References: <20040506185603.GM23287@polop.usc.edu> <20040506191351.GP23287@polop.usc.edu> <20040506215311.GA26968@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BLrIa-0008Iv-R1
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 15:25:00 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BLrIa-0003ax-Av
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 15:25:00 -0700
Received: from bfields by pumpkin.fieldses.org with local (Exim 4.32)
	id 1BLrIV-0005dl-Kq
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 18:24:55 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <20040506215311.GA26968@polop.usc.edu>
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

On Thu, May 06, 2004 at 02:53:11PM -0700, Garrick Staples wrote:
> I'm at a total loss.  Everything I'm reading tells me that all I need to ensure
> is that fs device names are the same on both servers so that the generated
> filehandles are the same, and that I need to move all lines matching
> ":$mountpoint:" in rmtab to the new server.  The former is done since I'm using
> persistant device numbers with lvm.  The latter shouldn't be needed because I'm
> using the "new" proc interface with 2.6.5.
> 
> rmtab definitly doesn't do any noticable difference.  I can add random text
> and blank it out with no noticable difference on the clients.
> 
> Is this a client problem?  The clients are all 2.4.24 and 2.4.26.
> 
> All clients and servers are using vanilla kernels.

I'm assuming /etc/exports is the same, and that the nfsd filesystem is
mounted (probably on /proc/fs/nfs/) and mountd is running without
complaint on the server that you're failing over to?

The kernel uses upcalls to mountd in part to construct the filehandles,
and nfserr_stale could be returned if those upcalls weren't working.
You can see the contents of the caches that hold the result of those
upcalls with something like

for i in `find /proc/net/rpc -name "content"`; do echo -e "\n$i:"; cat $i; done

Maybe the output from that (after a failed failover) would be
enlightening.

Hmm, also, could you try recompiling mountd with the following patch
applied?

--Bruce Fields


mountd needs to make sure that its internal state is synchronized with
etab before responding to kernel upcalls.


 utils/mountd/cache.c |    6 ++++++
 1 files changed, 6 insertions(+)

diff -puN utils/mountd/cache.c~upcall_export_check utils/mountd/cache.c
--- nfs-utils-1.0.6/utils/mountd/cache.c~upcall_export_check	2004-01-26 18:43:51.000000000 -0500
+++ nfs-utils-1.0.6-bfields/utils/mountd/cache.c	2004-01-26 18:43:51.000000000 -0500
@@ -67,6 +67,8 @@ void auth_unix_ip(FILE *f)
 	if (inet_aton(ipaddr, &addr)==0)
 		return;
 
+	auth_reload();
+
 	/* addr is a valid, interesting address, find the domain name... */
 	client = client_compose(addr);
 
@@ -138,6 +140,8 @@ void nfsd_fh(FILE *f)
 		break;
 	}
 
+	auth_reload();
+
 	/* Now determine export point for this fsid/domain */
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
 		for (exp = exportlist[i]; exp; exp = exp->m_next) {
@@ -236,6 +240,8 @@ void nfsd_export(FILE *f)
 	if (qword_get(&cp, path, strlen(lbuf)) <= 0)
 		goto out;
 
+	auth_reload();
+
 	/* now find flags for this export point in this domain */
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
 		for (exp = exportlist[i]; exp; exp = exp->m_next) {

_


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
