From: Peter Staubach <staubach@redhat.com>
Subject: Re: mount.nfs: chk_mountpoint()
Date: Thu, 23 Aug 2007 16:12:30 -0400
Message-ID: <46CDEA2E.10902@redhat.com>
References: <46CC884B.1030207@oracle.com> <46CD82A0.1000408@redhat.com>
	<46CDC7D0.6030803@oracle.com> <46CDD069.3070608@redhat.com>
	<46CDE76C.3040800@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOJ2p-00010U-UC
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 13:12:44 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOJ2r-0002Qv-WA
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 13:12:48 -0700
In-Reply-To: <46CDE76C.3040800@oracle.com>
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

Chuck Lever wrote:
> Peter Staubach wrote:
>> But your explanation makes sense, although we should be moving
>> people away from static mounts in fstab and towards dynamic
>> mounting via autofs.  Ian and Jeff have made autofs much, much
>> better in recent times.  Improving autofs further to make it
>> only mount file systems which are actually referenced would make
>> it even better.
>
> I'm in great favor of autoconfiguration.  Anything that will make NFS 
> "just work" is goodness, in my book.
>

Is this an argument for or against autofs or these changes?

>> How do we find out whether we need to continue supporting this
>> semantic or whether we can do away with it?  Clearly, if it was
>> busted, then not many people were depending upon it because
>> there didn't seem to be any hue and cry about it not working.
>
> Well, that change went into nfs-utils in May of 2007, only 3 months 
> ago.  Depending on when nfs-utils-1.1.0 got into Fedora 7, I don't 
> think the change has had wide exposure quite yet.
>
> Considering there hasn't been much "hue and cry" about "bg" not 
> working in Fedora, however, that may not be much of a standard by 
> which to measure customer dissatisfaction.

I would guess that not so many people are using the "bg" option,
period.  Many of Linux's customers are ex-Sun customers and they
were educated to use autofs and to move away from and stay away
from static mounts via fstab or vfstab.

The "bg" option was a hack added to speed up system booting.
A much better solution to the problem was autofs because it
delayed the mounting until the file system was actually needed.

The "bg" option can lead to applications not working correctly
because the file system may or may not be mounted when they
need it to be there and there is no automatic synchronization
to block them until it is.  Autofs supplies this synchronization,
thus once again, making it a vastly superior solution.

    Thanx...

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
