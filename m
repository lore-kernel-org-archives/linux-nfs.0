From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs sec=krb5 on RHEL and CentOS
Date: Wed, 24 Jan 2007 06:05:55 -0500
Message-ID: <45B73D93.1020508@RedHat.com>
References: <a3b675320701211411r45d010f8jd7132deedcf68804@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: james bardin <jbardin@bu.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9fwp-00065K-C6
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 03:05:47 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H9fwq-0004Nf-VM
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 03:05:49 -0800
In-Reply-To: <a3b675320701211411r45d010f8jd7132deedcf68804@mail.gmail.com>
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


Sorry for the delayed response...

james bardin wrote:
> I couldn't get sec=krb5 to work on clients running RHEL4 (and CentOS),
> so I built a slightly newer version of nfs-utils. (nfs-utils-1.0.7-13)
Go back and grab the latest rhel4 nfs-utils which is 1.0.6-77. That has
been updated with a number of patches that are in the upstream
version...

> 
> A mkdir return a file exists error, but the directory is created.
> Redirecting std out to a file returns an ioerror, and the file is
> created but empty.
> Vim creates swap files, they fail so it doesn't use them, but reports
> them as existing.
> 
> I can chmod, chown existing files as expected.
hmm... if this continues after you updated your nfs-utils, please
open a bug reported and post a bzip2 binary tethereal trace
something similar to:
     tethereal -w /tmp/data.pcap host <server> ; bzip2 /tmp/data.pcap

steved.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
