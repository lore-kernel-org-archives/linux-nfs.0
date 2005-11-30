From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: NFS cache consistancy appears to be broken...
Date: Tue, 29 Nov 2005 21:38:02 -0500
Message-ID: <438D108A.6020709@pobox.com>
References: <200510281607.j9SG7Tll024133@hera.kernel.org> <438D0E80.2020905@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EhHrR-0007gT-2e
	for nfs@lists.sourceforge.net; Tue, 29 Nov 2005 18:38:21 -0800
Received: from mail.dvmed.net ([216.237.124.58])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EhHrP-0005eJ-VO
	for nfs@lists.sourceforge.net; Tue, 29 Nov 2005 18:38:21 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <438D0E80.2020905@RedHat.com>
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

Steve Dickson wrote:
> Hey Trond,
> 
> The attached patch seems to break cache consistence in a big way....
> Doing the following:
> 1. On server:
> $ mkdir ~/t
> $ echo Hello > ~/t/tmp
> 
> 2. On client, wait for a string to appear in this file:
> $ until grep -q foo t/tmp ; do echo -n . ; sleep 1 ; done
> 
> 3. On server, create a *new* file with the same name containing that 
> string:
> $ mv ~/t/tmp ~/t/tmp.old; echo foo > ~/t/tmp
> 
> will shows how the client will never (and I mean never ;-) ) see
> the updated file. I reverted this patch and everything started
> work as expected... so it appears using a jiffy-based cache
> verifiers may not be such a good idea....
> 
> Note: I am using 2.6.15-rc2 kernel.

Very interesting.  This sounds similar to the problem I reported a week 
or so ago.  The circumstances were too unique to easily reproduce.

	Jeff






-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
