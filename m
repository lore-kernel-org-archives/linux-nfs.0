From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Write delay optimization question
Date: Tue, 29 Jun 2004 12:01:40 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1088524900.3882.25.camel@lade.trondhjem.org>
References: <2633.67.70.212.198.1088523688.squirrel@mail.nicker.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BfL3L-0001dy-3z
	for nfs@lists.sourceforge.net; Tue, 29 Jun 2004 09:01:47 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BfL3J-0006jB-Fz
	for nfs@lists.sourceforge.net; Tue, 29 Jun 2004 09:01:45 -0700
To: peter@nicker.net
In-Reply-To: <2633.67.70.212.198.1088523688.squirrel@mail.nicker.net>
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

P=E5 ty , 29/06/2004 klokka 11:41, skreiv peter@nicker.net:

> Is there a tunable parameter somewhere that would allow me to increase th=
e
> write buffering?  In the exports man page under no_wdelay it states "The
> NFS server will normally delay committing a write request to disc slightl=
y
> if it suspects another related write request may be in progress or may
> arrive soon."  If I could increase this delay it might help my problem,
> but I haven't been able to find it in the source.

The "wdelay" parameter should normally have no effect on NFSv3. Your
problem is probably the fact that the NFS clients are limited to a
maximum of 256 outstanding pages before they call COMMIT (which triggers
an fsync() call on the server). There is also a timer that triggers a
commit every 5 seconds in order to clean out older writes.

I'd therefore try bumping the client parameters NFS_COMMIT_DELAY and
MAX_REQUEST_HARD.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
