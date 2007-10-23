From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: libnfsidmap
Date: Tue, 23 Oct 2007 10:22:35 -0400
Message-ID: <4d569c330710230722y2e4dedeesb55a0d5c605f1fc8@mail.gmail.com>
References: <1193136846.5620.504.camel@serendib.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, Greg Banks <gnb@sgi.com>
To: Harshula <harshula@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IkKeP-0004Hw-QV
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 07:22:33 -0700
Received: from rv-out-0910.google.com ([209.85.198.190])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IkKeT-0007JP-Vl
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 07:22:39 -0700
Received: by rv-out-0910.google.com with SMTP id g11so5255699rvb
	for <nfs@lists.sourceforge.net>; Tue, 23 Oct 2007 07:22:35 -0700 (PDT)
In-Reply-To: <1193136846.5620.504.camel@serendib.melbourne.sgi.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 10/23/07, Harshula <harshula@sgi.com> wrote:
> Hi Bruce,
>
> We are building nfs-utils 1.0.7 with libnfsidmap 0.20 to avoid a bug
> with userid mappings in libnfsidmap 0.12.
>
> Then we tripped over nfs/<FQDN> principals not being resolved. Luckily I
> came across:
> http://linux-nfs.org/pipermail/nfsv4/2006-June/004564.html
>
> and realised that the code to handle nfs/<FQDN> principals is now in
> nfs-utils (utils/gssd/svcgssd_proc.c).
>
> Are there any other known issues we might trip over as a result of using
> nfs-utils 1.0.7 with libnfsidmap 0.20?
>
> Thanks,
> #

Sorry for the troubles.  I'm not Bruce, but AFAIK there aren't other
issues, and it should always be safe to use the latest libraries.

K.C.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
