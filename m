From: trond.myklebust@fys.uio.no
Subject: RE: [PATCH 2.6.3] Add write throttling to NFS client
Date: Mon, 1 Mar 2004 18:38:47 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <34574.207.214.87.84.1078162727.squirrel@webmail.uio.no>
References: <20040301081456.37082.qmail@web12823.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: "Bogdan Costescu" <bogdan.costescu@iwr.uni-heidelberg.de>,
     "Charles Lever" <Charles.Lever@netapp.com>,
     "Olaf Kirch" <okir@suse.de>,"Greg Banks" <gnb@melbourne.sgi.com>,
     nfs@lists.sourceforge.net,Shantanu.Goel@lehman.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AxrVp-0002dz-4R
	for nfs@lists.sourceforge.net; Mon, 01 Mar 2004 09:47:29 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AxrAF-0001f6-85
	for nfs@lists.sourceforge.net; Mon, 01 Mar 2004 09:25:11 -0800
To: "Shantanu Goel" <sgoel01@yahoo.com>
In-Reply-To: <20040301081456.37082.qmail@web12823.mail.yahoo.com>
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

På må , 01/03/2004 klokka 00:14, skreiv Shantanu Goel:
> I did not make that assumption.  It does not appear to
> be a problem in practice.   I ran 4 dd's each writing
> 256MB in parallel on a machine with 2 CPUs and 64MB
> memory and it chugged along fine and still allowed
> other NFS activity on the same mount point. However, I
> believe this reflects the  way the NFS layer is
> implemented  (most request ARE submitted by the writing
> process except in the case of less than a page worth
> of writes).  However, if that were to ever change,
> your argument will probably be valid.

Sigh... See the patch linux-2.6.3-02-strategy.dif on the usual patch site.
People are asking that we cache more than is currently done in order to
allow for better random write performance.

> > Yes, or alternatively, just give the tasks a numeric
> > priority. That's all
> > we do for real tasks after all...
> >
>
> Just assigning a priority to requests will not fix the
> issue.  The whole reason I started looking at this was
> heavy writing to a single inode blocks out all other
> async write activity.  To give a concrete example.
> Start a dd in the background and then start Mozilla.
> Even if you give priority to sync requests, Mozilla
> will hang when it writes its cache files because to
> the RPC layer, one async write will look the same as
> the next.  The RPC layer must segregate tasks based on
> some criteria.  I chose to use the process id which
> seems to work pretty well in practice with the current
> implementation of NFS.  So I see no way around
> batching tasks based on either a cookie or process id.

Huh? Just have the asynchronous tasks sit in a different priority bucket
to the synchronous ones and schedule, say 4 asynchronous tasks for every 1
synchronous one. Why would this be so difficult?

Cheers,
  Trond





-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
