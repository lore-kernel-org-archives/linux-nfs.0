From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] exponential backoff for blocked LOCK call polling
Date: Tue, 9 Nov 2004 10:17:04 +0100
Message-ID: <20041109091704.GA14350@suse.de>
References: <1098786131.21421.484.camel@hole.melbourne.sgi.com> <Pine.LNX.4.60.0411081021570.16292@harp.ngdc.noaa.gov> <20041108225411.GA29190@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>,
	Greg Banks <gnb@melbourne.sgi.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CRS8R-0000o8-43
	for nfs@lists.sourceforge.net; Tue, 09 Nov 2004 01:17:55 -0800
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CRS8P-0001pp-Bf
	for nfs@lists.sourceforge.net; Tue, 09 Nov 2004 01:17:54 -0800
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20041108225411.GA29190@sgi.com>
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

On Tue, Nov 09, 2004 at 09:54:11AM +1100, Greg Banks wrote:
> Not if the server has queued the lock request.  But then if the server
> were correctly implemented it would probably be sending us a GRANTED
> callback and we wouldn't need to poll.

The Linux lockd should send a GRANTED message. The only reason I
implemented polling was as a workaround against broken lockd's that would
never send GRANTED messages if you used the (synchronous) NLM_LOCK call
instead of the (asynchronous) NLM_LOCK_MSG. HPUX 10.something was one
of them.

I agree though that the polling code is bad because it masks potential
bugs in the Linux lockd.

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #1:
okir@suse.de   |        "I want to use NFS over AX25, can you help me?"
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
