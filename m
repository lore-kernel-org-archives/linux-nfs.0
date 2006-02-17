From: Olaf Kirch <okir@suse.de>
Subject: Re: Re: NFS lock reclaiming not working on SLES9 SP2
Date: Fri, 17 Feb 2006 12:07:56 +0100
Message-ID: <20060217110756.GF25707@suse.de>
References: <20060217104842.5424.qmail@webmail24.rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb@melbourne.sgi.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FA3T0-0008TO-J9
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 03:08:02 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FA3Sx-0003Oq-Sj
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 03:08:02 -0800
To: asha yr <asha_yr@rediffmail.com>
In-Reply-To: <20060217104842.5424.qmail@webmail24.rediffmail.com>
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

On Fri, Feb 17, 2006 at 10:48:42AM -0000, asha  yr wrote:
> I am comparing the working of NFS lock recovery feature on different
> updates of SLES9 and Redhat4. So I dont want to test the feature by
> applying any patch. Anyway, thanks for the patch.

Hm, I thought posting to a developer list normally indicates willingness
to try out patches to narrow down the problem. That's why it is a free
service, unlike the business support we offer (the difference being that
they would build a test kernel for you, using this exact same patch :-)

> Feb 17 16:10:07 sgmlx2 kernel: NFS lockd/statd started (ver 0.5).
> Feb 17 16:10:23 sgmlx2 kernel: lockd: request from 0f46bfac
> Feb 17 16:10:23 sgmlx2 kernel: lockd: nlm_host_rebooted("sgmlx1")
> Feb 17 16:10:30 sgmlx2 kernel: lockd: nlm_lookup_host(0f46bfac, p=6, v=4, my role=client, name=sgmlx1)
> Feb 17 16:10:30 sgmlx2 kernel: lockd: host garbage collection
> Feb 17 16:10:30 sgmlx2 kernel: lockd: nlmsvc_mark_resources

Hm, it still doesn't find the host. Please provide the line in
/proc/mounts for this NFS mount.

Thanks,
Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
