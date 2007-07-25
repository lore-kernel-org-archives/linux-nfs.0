From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] NFS: have string-based mount options default to "intr"
	mounts
Date: Wed, 25 Jul 2007 17:07:15 -0400
Message-ID: <46A7BB83.1000106@redhat.com>
References: <20070725145614.e17ca721.jlayton@redhat.com>	<46A7A632.2050900@oracle.com>	<20070725154107.063c3b9a.jlayton@redhat.com>	<1185394617.6585.135.camel@localhost>
	<20070725164323.d2cc9212.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20070725164323.d2cc9212.jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

Jeff Layton wrote:
> On Wed, 25 Jul 2007 16:16:57 -0400
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>
>   
>> On Wed, 2007-07-25 at 15:41 -0400, Jeff Layton wrote:
>>     
>>> On Wed, 25 Jul 2007 15:36:18 -0400
>>> Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>>       
>>>> I thought "nointr" was the default because it is safest.
>>>>
>>>>         
>>> I could see maybe with soft mounts, but in conjunction with a hard
>>> mount (which is the default) is there danger of corruption?
>>>       
>> You may cause the sync to disk on close() to be aborted. The writes will
>> eventually get flushed to disk by the flushd() daemon, but failing to
>> sync writes to disk prior to closing the file is a violation of
>> close-to-open caching semantics and may cause corruption issues.
>>
>> Trond
>>
>>     
>
> The close would return EINTR in this case though, wouldn't it? The app
> should then be aware that it didn't actually happen and should
> reattempt it. Presuming that the app handles this correctly, is it
> really a data corruption issue?

You can't retry the operation.  Even if close() returns an error,
the file descriptor is really closed.

But, the application can take some other form of error recovery.

----

I think that I object the data corruption characterization.  The
data doesn't become corrupted.  It, eventually, is written out to
stable storage.  However, an application which concerned with
consistency needs to be able to do something valid when a close
operation returns an error, whether it is EINTR or something else.

    Thanx...

       ps
