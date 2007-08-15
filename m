From: Neil Brown <neilb@suse.de>
Subject: Re: Compilation Error nfs-utils-1.1.0
Date: Thu, 16 Aug 2007 09:41:06 +1000
Message-ID: <18115.36626.71550.314140@notabene.brown>
References: <862A0FDF1A4DC647A442EFD270291F7301AE5335@MAILSJ2.global.cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Mitch Sako" <msako@cadence.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILSUE-0001cj-Fp
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 16:41:14 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ILSUF-00044t-9y
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 16:41:15 -0700
In-Reply-To: message from Mitch Sako on Wednesday August 15
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

On Wednesday August 15, msako@cadence.com wrote:
> When I try to build 1.1.0 it gives this error message inside of
> ./mountd:
> 
> [root mountd]$ make
> /bin/sh ../../libtool --tag=CC   --mode=link gcc -Wall  -pipe -g -O2
> -o mountd mountd-mountd.o mountd-mount_dispatch.o mountd-auth.o
> mountd-rmtab.o mountd-cache.o mountd-svc_run.o mountd-fsloc.o
> ../../support/export/libexport.a ../../support/nfs/libnfs.a
> ../../support/misc/libmisc.a  -lwrap  -lblkid 
> gcc -Wall -pipe -g -O2 -o mountd mountd-mountd.o mountd-mount_dispatch.o
> mountd-auth.o mountd-rmtab.o mountd-cache.o mountd-svc_run.o
> mountd-fsloc.o  ../../support/export/libexport.a
> ../../support/nfs/libnfs.a ../../support/misc/libmisc.a -lwrap -lblkid
> /usr/lib/libblkid.a(probe.o): In function `set_uuid':
> /usr/local/e2fsprogs-1.40.2/lib/blkid/probe.c:128: undefined reference
> to `uuid_is_null'
> /usr/local/e2fsprogs-1.40.2/lib/blkid/probe.c:129: undefined reference
> to `uuid_unparse'
> /usr/lib/libblkid.a(probe.o): In function `probe_ext3':
> /usr/local/e2fsprogs-1.40.2/lib/blkid/probe.c:176: undefined reference
> to `uuid_is_null'
> collect2: ld returned 1 exit status
> make: *** [mountd] Error 1
> 
> I suspect I may have built e2fsprogs or uuid incorrectly? 

Maybe... but it seems that the uuid_ function are in a separate
library: libuuid.
And while libblkid.so depends on libuuid.so, there is no similar
relationship between libblkid.a and libuuid.a.  so if you are doing a
static link (which seems to be the case??) you will need to list
-luuid as well.  And maybe -ldevmapper.


> 1.0.6 does not have this link error.

1.0.6 does not use libblkid.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
