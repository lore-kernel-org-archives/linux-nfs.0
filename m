From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: [PATCH] exponential backoff for blocked LOCK call polling
Date: Mon, 8 Nov 2004 16:17:09 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0411081613030.9736@harp.ngdc.noaa.gov>
References: <1098786131.21421.484.camel@hole.melbourne.sgi.com>
 <Pine.LNX.4.60.0411081021570.16292@harp.ngdc.noaa.gov> <20041108225411.GA29190@sgi.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Greg Banks <gnb@melbourne.sgi.com>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CRIl9-0001gK-QU
	for nfs@lists.sourceforge.net; Mon, 08 Nov 2004 15:17:15 -0800
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CRIl8-0007BS-9N
	for nfs@lists.sourceforge.net; Mon, 08 Nov 2004 15:17:15 -0800
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

On Tue, 9 Nov 2004, Greg Banks wrote:

>>  this will mean that a client waiting a long time has an increasingly
>>  significant change of being starved when a lock is under heavy contention
>>  doesn't it?
>
> Not if the server has queued the lock request.  But then if the server were
> correctly implemented it would probably be sending us a GRANTED callback and
> we wouldn't need to poll.

i figured as much - wan't quite sure the reason for the poll...

>>  in any case it seems like resetting the delay to min after reaching max
>>  (becoming impatient again) may give better performance on average than
>>  simply staying at max.
>
> Could do.  Do you want to do the patch?

i could - but not for a week or more... all i was really thinking is

   delay =
     delay < NLM_LOCK_RETRY_DELAY_MAX ? delay << 1 : NLM_LOCK_RETRY_DELAY_MIN;

cheers.

-a
--
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
