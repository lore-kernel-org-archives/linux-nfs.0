From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS write errors
Date: Wed, 13 Oct 2004 16:12:34 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <416D8C32.8000801@RedHat.com>
References: <1097686177.8133.2915.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CHpUc-00038F-9O
	for nfs@lists.sourceforge.net; Wed, 13 Oct 2004 13:13:02 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CHpUa-00043p-Kd
	for nfs@lists.sourceforge.net; Wed, 13 Oct 2004 13:13:02 -0700
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1097686177.8133.2915.camel@tesuji.nac.uci.edu>
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

>We are occasionally getting NFS write errors when writing terrabytes of
>data from an AIX 5.1 system to an RHEL 3 system, using the version of
>in-kernel NFS that comes with RHEL 3.  We're using 8k rsize, 8k wsize,
>nfs v3, and tcp presently, but this isn't written in stone.
>  
>
What kind of errors? Is there anything in either /var/log/messages
that talk about some error condition? What kernel are we talking about?

SteveD.


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
