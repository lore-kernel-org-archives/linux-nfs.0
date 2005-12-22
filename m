From: Vince Busam <vbusam@google.com>
Subject: Re: segfault in mount with CITI patch
Date: Thu, 22 Dec 2005 15:43:29 -0800
Message-ID: <43AB3A21.6010503@google.com>
References: <43AA01AA.3060705@google.com> <1135292911.3685.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Epa63-0008Sy-Vf
	for nfs@lists.sourceforge.net; Thu, 22 Dec 2005 15:43:43 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Epa62-0003yb-Om
	for nfs@lists.sourceforge.net; Thu, 22 Dec 2005 15:43:44 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1135292911.3685.4.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

Trond Myklebust wrote:
> On Wed, 2005-12-21 at 17:30 -0800, Vince Busam wrote:
> 
>>Is nfsvers=3,mountvers=2 even OK to do?  If not, mount should print an error instead of 
>>segfault.
> 
> 
> Do you mean that the kernel Oopses, or is it really just a userland
> segfault. If the latter, we really don't care too much: mixing nfsvers=3
> and mountvers=2 is just silly. Sure, we can put a check in util-linux,
> but there is no security implication.


It's a harmless userland segfault that could be fixed with a simple check like this (or a 
more thorough one if somebody has more knowledge over which versions don't work together).

Vince

--- util-linux-2.12.nfsv4/mount/nfsmount.c.orig 2005-12-21 15:56:02.000000000 -0800
+++ util-linux-2.12.nfsv4/mount/nfsmount.c      2005-12-22 13:51:33.000000000 -0800
@@ -803,6 +803,10 @@ nfsmnt_check_compat(const struct pmap *n
                         mnt_pmap->pm_vers);
                 goto out_bad;
         }
+       if ((nfs_pmap->pm_vers == 3) && (mnt_pmap->pm_vers < 3)) {
+               fprintf(stderr, _("NFS version 3 not supported with mount < 3\n"));
+               goto out_bad;
+       }
         return 1;
   out_bad:
         return 0;


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
