From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: [PATCH] exponential backoff for blocked LOCK call polling
Date: Mon, 8 Nov 2004 10:27:19 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0411081021570.16292@harp.ngdc.noaa.gov>
References: <1098786131.21421.484.camel@hole.melbourne.sgi.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CRDIg-0000L7-Pu
	for nfs@lists.sourceforge.net; Mon, 08 Nov 2004 09:27:30 -0800
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CRDIe-0000yV-9z
	for nfs@lists.sourceforge.net; Mon, 08 Nov 2004 09:27:30 -0800
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1098786131.21421.484.camel@hole.melbourne.sgi.com>
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

On Tue, 26 Oct 2004, Greg Banks wrote:

> G'day,
>
> The attached patch makes the NLM client do exponential backoff
> for the polling used to handle the case that the server has not
> sent a GRANTED callback.
>
> Greg.
> --
> Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> I don't speak for SGI.

i implemented something exactly like this in userland for some code for which
many ( > 30) hosts are competing for a lock.  i didn't want to use blocking
locks as the performance was terrible (seeing one host obtain the lock
thousands of time in a row).  instead i used non-blocking locks with the
following algorithim for backing off:

   - client becomes more and more patient (similar to your exponential backoff
     - mine is linear though)

   - client eventually becomes impatient again

if i read your code right it looks like, once max delay is reached, it stays
there.  this will mean that a client waiting a long time has an increasingly
significant change of being starved when a lock is under heavy contention
doesn't it?  in any case it seems like resetting the delay to min after
reaching max (becoming impatient again) may give better performance on average
than simply staying at max.

kind regards.

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
