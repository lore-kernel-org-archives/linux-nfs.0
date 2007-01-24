From: James Bardin <jbardin@bu.edu>
Subject: Re: nfs sec=krb5 on RHEL and CentOS
Date: Wed, 24 Jan 2007 10:03:52 -0500
Message-ID: <45B77558.4080700@bu.edu>
References: <a3b675320701211411r45d010f8jd7132deedcf68804@mail.gmail.com>
	<45B73D93.1020508@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9jff-00053T-KY
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 07:04:19 -0800
Received: from wr-out-0506.google.com ([64.233.184.227])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H9jfc-0007fr-6b
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 07:04:18 -0800
Received: by wr-out-0506.google.com with SMTP id i20so142843wra
	for <nfs@lists.sourceforge.net>; Wed, 24 Jan 2007 07:03:54 -0800 (PST)
In-Reply-To: <45B73D93.1020508@RedHat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net



Steve Dickson wrote:
>
> Sorry for the delayed response...
That's ok, thanks for the assistance. This is kind of a show stopper for 
us, as we have to be standardized on RHEL/CentOS this summer.
I does work with a new kernel (2.6.19.2), but that's not feasible for 
our entire install base right now.

> Go back and grab the latest rhel4 nfs-utils which is 1.0.6-77. That has
> been updated with a number of patches that are in the upstream
> version...
>
Can you point me to the package? I can't seem to find anything but 
nfs-utils-1.0.6-70.EL4.src.rpm (from redhat's ftp site), and this is the 
version I started with.

thanks
-jim



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
