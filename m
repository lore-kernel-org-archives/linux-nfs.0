From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] exponential backoff for blocked LOCK call polling
Date: Tue, 9 Nov 2004 09:54:11 +1100
Message-ID: <20041108225411.GA29190@sgi.com>
References: <1098786131.21421.484.camel@hole.melbourne.sgi.com> <Pine.LNX.4.60.0411081021570.16292@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb@melbourne.sgi.com>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CRITl-0005ET-9k
	for nfs@lists.sourceforge.net; Mon, 08 Nov 2004 14:59:17 -0800
Received: from omx3-ext.sgi.com ([192.48.171.20] helo=omx3.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CRITi-0005AO-JI
	for nfs@lists.sourceforge.net; Mon, 08 Nov 2004 14:59:17 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0411081021570.16292@harp.ngdc.noaa.gov>
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

On Mon, Nov 08, 2004 at 10:27:19AM -0700, Ara.T.Howard wrote:
> On Tue, 26 Oct 2004, Greg Banks wrote:
> if i read your code right it looks like, once max delay is reached, it stays
> there.

Yes.

>  this will mean that a client waiting a long time has an increasingly
> significant change of being starved when a lock is under heavy contention
> doesn't it?

Not if the server has queued the lock request.  But then if the server
were correctly implemented it would probably be sending us a GRANTED
callback and we wouldn't need to poll.

>  in any case it seems like resetting the delay to min after
> reaching max (becoming impatient again) may give better performance on 
> average
> than simply staying at max.

Could do.  Do you want to do the patch?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
