From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Re: NFS lock reclaiming not working on SLES9 SP2
Date: Mon, 20 Feb 2006 22:00:24 +1100
Message-ID: <1140433224.2100.153.camel@hole.melbourne.sgi.com>
References: <20060217104842.5424.qmail@webmail24.rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Olaf Kirch <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FB8mI-0004Hc-MI
	for nfs@lists.sourceforge.net; Mon, 20 Feb 2006 03:00:26 -0800
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FB8mH-0000Vu-JF
	for nfs@lists.sourceforge.net; Mon, 20 Feb 2006 03:00:26 -0800
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

On Fri, 2006-02-17 at 21:48, asha yr wrote:
> I tried mounting NFS file system using hostname on client. After
> sending notifications, sm-notify clears sm directory. Then the sm
> directory should get updated freshly with the client information. This
> is not happening.
> 
> The debugging messages of lockd on server and client are:
> 
> on client side
> [...]
> Feb 17 16:10:23 sgmlx2 kernel: lockd: request from 0f46bfac
> Feb 17 16:10:23 sgmlx2 kernel: lockd: nlm_host_rebooted("sgmlx1")
> Feb 17 16:10:30 sgmlx2 kernel: lockd: nlm_lookup_host(0f46bfac, p=6,
> v=4, my role=client, name=sgmlx1)
> [...]

Works fine on SP3 (if you mount by hostname):

Feb 20 01:43:57 4A:cocky kernel: lockd: request from 860e364f
Feb 20 01:43:57 4A:cocky kernel: statd: NOTIFY        called
Feb 20 01:43:57 4A:cocky kernel: lockd: nlm_host_rebooted("rosella")
Feb 20 01:43:57 4A:cocky kernel: lockd: rebind host rosella
Feb 20 01:43:57 4A:cocky kernel: NLM: reclaiming locks for host rosellalockd: get host rosella
Feb 20 01:43:57 4A:cocky kernel: lockd: release host rosella
Feb 20 01:43:57 4A:cocky kernel: nlmsvc_retry_blocked(0000000000000000, when=0)
Feb 20 01:43:57 4A:cocky kernel: nlmsvc_retry_blocked(0000000000000000, when=0)
Feb 20 01:43:57 4A:cocky kernel: lockd: call procedure 2 on rosella
Feb 20 01:43:57 4A:cocky kernel: lockd: nlm_bind_host(860e364f)
Feb 20 01:43:57 4A:cocky kernel: lockd: server returns status 0
Feb 20 01:43:57 4A:cocky kernel: lockd: release host rosella

Mounting by IP address is (unsurprisingly) as broken as SP2.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
