From: Steve Dickson <SteveD@redhat.com>
Subject: Re: no_acl?
Date: Fri, 04 Nov 2005 07:45:18 -0500
Message-ID: <436B57DE.8060207@RedHat.com>
References: <20051103225258.36123.qmail@web51914.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EY0wf-0003JV-J2
	for nfs@lists.sourceforge.net; Fri, 04 Nov 2005 04:45:25 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EY0wf-0002Y9-EC
	for nfs@lists.sourceforge.net; Fri, 04 Nov 2005 04:45:25 -0800
To: email builder <emailbuilder88@yahoo.com>
In-Reply-To: <20051103225258.36123.qmail@web51914.mail.yahoo.com>
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

email builder wrote:
>   I am trying to see if it is possible to specify no_acl for my exports (uh,
> sorry, I forget if this is a client-mount or server-export setting), but it
> does not appear to be implemented for the latest NFS package under Fedora
> (core 3).
ACLs are not available in the 2.6.9 kernel. I believe they came
in around 2.6.10 or 2.6.11.
> 
>   Am I just out of luck with Fedora and this option, or is there something
> I've overlooked?  I was advised that it could eliminate a lot of unecessary
> traffic and help performance noticably.
You'll need to upgrade to FC4 and then use the nfs-utils in Rawhide
to use the no_acl export option. I am assuming your talking about
nfsv3 acls...

steved.


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
