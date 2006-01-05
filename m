From: Olaf Kirch <okir@suse.de>
Subject: Re: lockd/statd: failed to create /var/lib/nfs/sm/<hostname>
Date: Thu, 5 Jan 2006 15:54:05 +0100
Message-ID: <20060105145405.GM25157@suse.de>
References: <200601051456.20478.engelmann@lrz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Helge.Hansemann@lrz-muenchen.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EuWVT-0000mP-UJ
	for nfs@lists.sourceforge.net; Thu, 05 Jan 2006 06:54:23 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EuWVS-0000T8-LI
	for nfs@lists.sourceforge.net; Thu, 05 Jan 2006 06:54:24 -0800
To: Herbert Engelmann <Herbert.Engelmann@lrz-muenchen.de>
In-Reply-To: <200601051456.20478.engelmann@lrz.de>
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

On Thu, Jan 05, 2006 at 02:56:18PM +0100, Herbert Engelmann wrote:
> Jan  5 10:58:10 xxxxxx kernel: lockd/statd: failed to create 
> /var/lib/nfs/sm/<full qualified hostname>: err=-2
> 
> Jan  5 10:58:10 xxxxxx kernel: lockd: failed to monitor <full qualified 
> hostname>

That seems to be a Suse kernel you're running. Which kernel is that?
Are you running the most recent update kernel?

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
