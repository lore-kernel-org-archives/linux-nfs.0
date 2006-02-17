From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: NFS lock reclaiming not working on SLES9 SP2
Date: Fri, 17 Feb 2006 20:37:05 +1100
Message-ID: <1140169024.31913.2313.camel@hole.melbourne.sgi.com>
References: <20060217044448.16069.qmail@webmail34.rediffmail.com>
	 <20060217092555.GA25707@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: asha yr <asha_yr@rediffmail.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FA23K-0004bg-SI
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 01:37:26 -0800
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FA23J-0000tC-ND
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 01:37:26 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20060217092555.GA25707@suse.de>
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

On Fri, 2006-02-17 at 20:25, Olaf Kirch wrote:
> Hi,
> 
> On Fri, Feb 17, 2006 at 04:44:48AM -0000, asha  yr wrote:
> > The reclaiming of locks was working fine on base SLES9. It started failing after I updated SLES9 with SP2.
> 
> Did you try SLES9 SP3? I remember we had some problems with lock reclaim,
> but I thought they were fixed in SP2.
>
> It would be useful to get a lockd trace on the server side, what it
> receives and what it sends back. The ethereal traces aren't very useful
> though; it seems the snaplen is too small (and binary dumps are usually
> much more helpful than the "helpful" ASCII packet representation that
> ethereal or tcpdump generate)

In his trace, the client wasn't sending any LOCK calls at all
for multiple minutes after receiving the NOTIFY.

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
