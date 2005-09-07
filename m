From: Peter Staubach <staubach@redhat.com>
Subject: Re: Some code, and a question
Date: Wed, 07 Sep 2005 13:27:45 -0400
Message-ID: <431F2311.4040908@redhat.com>
References: <1126046397.3000.188.camel@seki.nac.uci.edu>	 <20050907010219.GA14233@sgi.com>	 <1126103821.16701.8.camel@seki.nac.uci.edu>  <431EFF78.6000709@redhat.com>	 <1126112442.16701.17.camel@seki.nac.uci.edu>  <431F1FD5.4@redhat.com> <1126114111.16701.33.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Greg Banks <gnb@sgi.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ED3mk-0008CU-Fj
	for nfs@lists.sourceforge.net; Wed, 07 Sep 2005 10:32:34 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ED3mk-0007ff-78
	for nfs@lists.sourceforge.net; Wed, 07 Sep 2005 10:32:34 -0700
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1126114111.16701.33.camel@seki.nac.uci.edu>
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

Dan Stromberg wrote:

>
>I set up our QFS.  I made the QFS transfer size the same as the
>underlying stripe size in the underlying RAID 5's.  Is there more to it
>than that?  I studied some QFS notes that a QFS instructor shared with
>me, but I didn't see anything more about QFS tuning than that.
>

I don't know how to tune a QFS file system.  I do know that it was 
considered
to be a black art and LSC/Sun consulting would often get involved.

       ps


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
