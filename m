From: Neil Brown <neilb@suse.de>
Subject: Re: nfssvc: writting fds to kernel failed: errno 0 (Success)
Date: Mon, 12 Feb 2007 10:39:49 +1100
Message-ID: <17871.43333.241970.724805@notabene.brown>
References: <87fy9c5m0l.fsf@groumpf.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Arnaud Giersch <arnaud.giersch@free.fr>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGOIz-0007Ss-Hb
	for nfs@lists.sourceforge.net; Sun, 11 Feb 2007 15:40:25 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HGOJ1-0000jr-35
	for nfs@lists.sourceforge.net; Sun, 11 Feb 2007 15:40:27 -0800
In-Reply-To: message from Arnaud Giersch on Monday February 12
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

On Monday February 12, arnaud.giersch@free.fr wrote:
> Hi,
> 
> Since two months, I can see the following strange messages logged each
> time that rpc.nfsd is started:
> 
> Feb 11 21:46:23 bilbo nfsd[18672]: nfssvc: writting fds to kernel failed: errno 0 (Success)
> Feb 11 21:46:23 bilbo nfsd[18672]: nfssvc: writting fds to kernel failed: errno 0 (Success)
> 
> It seems however harmless, the NFS server works fine.  

Yes, it is harmless - except that it causes concern.

The following kernel patch should stop the error (and a separate patch
will fix the typo in the error message...)

Thanks,
NeilBrown

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff .prev/fs/nfsd/nfsctl.c ./fs/nfsd/nfsctl.c
--- .prev/fs/nfsd/nfsctl.c	2007-02-12 10:37:53.000000000 +1100
+++ ./fs/nfsd/nfsctl.c	2007-02-12 10:38:11.000000000 +1100
@@ -123,7 +123,7 @@ static ssize_t nfsctl_transaction_write(
 		return PTR_ERR(data);
 
 	rv =  write_op[ino](file, data, size);
-	if (rv>0) {
+	if (rv >= 0) {
 		simple_transaction_set(file, rv);
 		rv = size;
 	}

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
