From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: [NFS] nfs-utils crossmnt/fsid bug
Date: Fri, 07 Dec 2007 11:05:15 -0800
Message-ID: <1197054315.1215.21.camel@dyn9047022153>
References: <20070905204628.GD29582@fieldses.org>
	<18246.16373.177320.570040@notabene.brown>
	<1196722262.1215.5.camel@dyn9047022153>
	<18260.43206.943331.889058@notabene.brown>
	<1196790164.1215.9.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, ffilz@us.ibm.com,
	nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:59554 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757292AbXLGTHR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2007 14:07:17 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J0iXa-0007OT-Og
	for linux-nfs@vger.kernel.org; Sat, 08 Dec 2007 06:07:14 +1100
In-Reply-To: <1196790164.1215.9.camel@dyn9047022153>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've done some more exploration, I think the exports are getting set
wrong. First, here is the working case with the new exports format (cut
from an annotated /var/log/messages):

START======================================================
======= cat /etc/exports
/export		*(sec=krb5,fsid=0,insecure,no_subtree_check,no_root_squash,async)
/export/home	*(sec=krb5,nohide,insecure,no_subtree_check,no_root_squash,async)
======= mount -overs=4,sec=krb5 elm3a19.beaverton.ibm.com:/ /mnt
Dec  7 10:47:20 elm3a19 mountd[4691]: cache_export_ent domain=*, exp path=/export, path=/export 
Dec  7 10:47:20 elm3a19 mountd[4691]: dump_to_cache path=/export, exp path=/export 
======= ls -l /mnt
Dec  7 10:47:22 elm3a19 mountd[4691]: nfsd_export domain=*, path=/export/home, exp path=/export/home 
Dec  7 10:47:22 elm3a19 mountd[4691]: dump_to_cache path=/export/home, exp path=/export/home 
Dec  7 10:47:23 elm3a19 mountd[4691]: cache_export_ent domain=*, exp path=/export/home, path=/export/home 
Dec  7 10:47:23 elm3a19 mountd[4691]: dump_to_cache path=/export/home, exp path=/export/home 
======= umount /mnt
==========================
Dec  7 10:47:28 elm3a19 rpc.idmapd[2471]: nfsdcb: authbuf=gss/krb5 authtype=user
Dec  7 10:47:28 elm3a19 rpc.idmapd[2471]: nfsdcb: authbuf=gss/krb5 authtype=group
======= ls -l /mnt/home
======= umount /mnt
END=======================================================


And then here is the non-working form with the old exports format:

START======================================================
======= cat /etc/exports
/export/home	gss/krb5i(nohide,insecure,no_subtree_check,no_root_squash,async,rw)
/export/home	gss/krb5p(nohide,insecure,no_subtree_check,no_root_squash,async,rw)
/export         gss/krb5(fsid=0,insecure,no_subtree_check,no_root_squash,async,rw,crossmnt)
/export         gss/krb5i(fsid=0,insecure,no_subtree_check,no_root_squash,async,rw,crossmnt)

======= mount -overs=4,sec=krb5 elm3a19.beaverton.ibm.com:/ /mnt
Dec  7 10:46:53 elm3a19 mountd[4691]: cache_export_ent domain=gss/krb5, exp path=/export, path=/export 
Dec  7 10:46:53 elm3a19 mountd[4691]: dump_to_cache path=/export, exp path=/export 
======= ls -l /mnt
Dec  7 10:46:55 elm3a19 mountd[4691]: nfsd_export domain=gss/krb5, path=/export/home, exp path=/export 
Dec  7 10:46:55 elm3a19 mountd[4691]: dump_to_cache path=/export/home, exp path=/export 
Dec  7 10:46:56 elm3a19 mountd[4691]: cache_export_ent domain=gss/krb5, exp path=/export, path=/export/home 
Dec  7 10:46:56 elm3a19 mountd[4691]: dump_to_cache path=/export, exp path=/export 
Dec  7 10:46:56 elm3a19 mountd[4691]: dump_to_cache path=/export/home, exp path=/export 
======= umount /mnt
==========================
======= ls -l /mnt/home
======= umount /mnt
END=======================================================

I see that the way mountd caches the /exports/home export is different
between the two cases, with the non-working old exports format case
caching a path of /export/home but using the /export export.

p.s. I am using nfs-utils-1.1.1 for this, and applied the previously
mentioned crossmount patch.

Oh, and just for completeness, here is implicit exporting via crossmnt,
with the same result:

START======================================================
======= cat /etc/exports
/export
gss/krb5(fsid=0,insecure,no_subtree_check,no_root_squash,async,rw,crossmnt)
/export
gss/krb5i(fsid=0,insecure,no_subtree_check,no_root_squash,async,rw,crossmnt)

======= mount -overs=4,sec=krb5 elm3a19.beaverton.ibm.com:/ /mnt
Dec  7 11:00:22 elm3a19 mountd[4691]: cache_export_ent domain=gss/krb5, exp path=/export, path=/export 
Dec  7 11:00:22 elm3a19 mountd[4691]: dump_to_cache path=/export, exp path=/export 
Dec  7 11:00:22 elm3a19 rpc.idmapd[2471]: nfsdcb: authbuf=gss/krb5 authtype=user
Dec  7 11:00:22 elm3a19 rpc.idmapd[2471]: nfsdcb: authbuf=gss/krb5 authtype=group
======= ls -l /mnt
Dec  7 11:00:24 elm3a19 mountd[4691]: nfsd_export domain=gss/krb5, path=/export/home, exp path=/export 
Dec  7 11:00:24 elm3a19 mountd[4691]: dump_to_cache path=/export/home, exp path=/export 
Dec  7 11:00:25 elm3a19 mountd[4691]: cache_export_ent domain=gss/krb5, exp path=/export, path=/export/home 
Dec  7 11:00:25 elm3a19 mountd[4691]: dump_to_cache path=/export, exp path=/export 
Dec  7 11:00:25 elm3a19 mountd[4691]: dump_to_cache path=/export/home, exp path=/export 
======= umount /mnt
==========================
======= ls -l /mnt/home
======= umount /mnt
END=======================================================

Looks the same as with the explicit exporting.

Any suggestions or thoughts?

Thanks

Frank Filz



-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

