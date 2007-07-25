From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] NFS: have string-based mount options default to
 "intr" mounts
Date: Wed, 25 Jul 2007 16:36:32 -0400
Message-ID: <46A7B450.3060304@redhat.com>
References: <20070725145614.e17ca721.jlayton@redhat.com>	<46A7A632.2050900@oracle.com>	<20070725154107.063c3b9a.jlayton@redhat.com>
	<1185394617.6585.135.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDnbA-0003AM-45
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 13:36:45 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IDnbC-0005p3-9e
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 13:36:46 -0700
In-Reply-To: <1185394617.6585.135.camel@localhost>
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

Trond Myklebust wrote:
> On Wed, 2007-07-25 at 15:41 -0400, Jeff Layton wrote:
>   
>> On Wed, 25 Jul 2007 15:36:18 -0400
>> Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>>     
>>> I thought "nointr" was the default because it is safest.
>>>
>>>       
>> I could see maybe with soft mounts, but in conjunction with a hard
>> mount (which is the default) is there danger of corruption?
>>     
>
> You may cause the sync to disk on close() to be aborted. The writes will
> eventually get flushed to disk by the flushd() daemon, but failing to
> sync writes to disk prior to closing the file is a violation of
> close-to-open caching semantics and may cause corruption issues.

It sounds like the sync to disk on close() needs to be done in a
separate context and have the process in close() wait on it?  That
way, the process which received the signal could abort and return
without waiting on all of the data to get flushed, but the data
would still get flushed in a timely fashion?

I suspect that as soon as you throw in a close() which returns
EINTR, then all assumptions about close-to-open become null and
void.

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
