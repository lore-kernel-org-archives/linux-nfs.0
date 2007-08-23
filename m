From: Peter Staubach <staubach@redhat.com>
Subject: Re: mount.nfs: chk_mountpoint()
Date: Thu, 23 Aug 2007 16:49:11 -0400
Message-ID: <46CDF2C7.5010105@redhat.com>
References: <46CC884B.1030207@oracle.com> <46CD82A0.1000408@redhat.com>
	<46CDC7D0.6030803@oracle.com> <46CDD069.3070608@redhat.com>
	<46CDE76C.3040800@oracle.com> <46CDEA2E.10902@redhat.com>
	<46CDEE5F.5030304@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOJcC-0004lK-MA
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 13:49:16 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOJcE-0004eQ-Pr
	for nfs@lists.sourceforge.net; Thu, 23 Aug 2007 13:49:21 -0700
In-Reply-To: <46CDEE5F.5030304@oracle.com>
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
>> Chuck Lever wrote:
>>> Peter Staubach wrote:
>>>> But your explanation makes sense, although we should be moving
>>>> people away from static mounts in fstab and towards dynamic
>>>> mounting via autofs.  Ian and Jeff have made autofs much, much
>>>> better in recent times.  Improving autofs further to make it
>>>> only mount file systems which are actually referenced would make
>>>> it even better.
>>>
>>> I'm in great favor of autoconfiguration.  Anything that will make 
>>> NFS "just work" is goodness, in my book.
>>>
>>
>> Is this an argument for or against autofs or these changes?
>
> Making autofs a reliable and useful facility is a good thing.  Kudos 
> to Ian and Jeff for their effort.
>
>> The "bg" option was a hack added to speed up system booting.
>
> I don't disagree with that assessment.
>
>> A much better solution to the problem was autofs because it
>> delayed the mounting until the file system was actually needed.
>
> Whether or not it is a kludge, I don't think we have enough 
> information about who is using it for what to blithely remove it 
> without fanfare or documentation.
>

I would agree completely.

> What alarms me more, though, is that we don't have any unit tests that 
> caught this change before it went into the git repo.  This change, in 
> itself, may not be terribly harmful.  But think of a minor and 
> unintended change that might go in without notice, and break a lot of 
> environments.
>

Well, then we'd hear pretty quickly, I think...

But yes, a test would be a better way to do it.  :-)

>> The "bg" option can lead to applications not working correctly
>> because the file system may or may not be mounted when they
>> need it to be there and there is no automatic synchronization
>> to block them until it is.  Autofs supplies this synchronization,
>> thus once again, making it a vastly superior solution.
>
> Some people find such enforced "synchronization" to be painful and 
> annoying.  They would prefer a solution where the application is free 
> to take its own recourse rather than hang indefinitely.
>
> I think it is valid to want to have either type of behavior.

This, I would agree with.  I still think that autofs is the right place
to put the appropriate synchronization, whether it be to block the
application or fail whatever system call that it was that attempted
to access the not yet mounted file system.

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
