From: Peter Staubach <staubach@redhat.com>
Subject: Re: umount fails with device busy
Date: Fri, 24 Aug 2007 09:43:47 -0400
Message-ID: <46CEE093.5050303@redhat.com>
References: <20070823184544.237460@gmx.net> <46CDE805.4090909@oracle.com>
	<46CDEE3A.3040809@redhat.com> <46CDEF90.90007@oracle.com>
	<46CDF3BE.9030509@redhat.com> <46CE03CB.4070300@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOZS1-0005Bn-RP
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 06:43:50 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOZS5-0007NC-RR
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 06:43:54 -0700
In-Reply-To: <46CE03CB.4070300@oracle.com>
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
>
>
> Peter Staubach wrote:
>> Chuck Lever wrote:
>>>>>> When I run umount during these ops I get an device busy. Any help 
>>>>>> would be very appreciated!
>>>>>
>>>>> This is normal and expected behavior.  One problem may be that 
>>>>> your server is slow, and thus there are RPCs left outstanding for 
>>>>> a bit on your client after your application exits.  The COMMIT 
>>>>> calls from that trace suggest that there is dirty data the client 
>>>>> is writing back to the server. 
>>>>
>>>> It seems to me that this should not be the expected behavior unless
>>>> the file system is mounted "nocto".  Is it?
>>>
>>> I'm a little puzzled myself about what dirty data there might be 
>>> left after the application quits.  However, I'll be there is an 
>>> mmap() lurking somewhere in the background...
>>>
>>> Data that was dirtied via a mapped file is not subject to the 
>>> writeback part of close-to-open.
>>
>> I don't think that I agree with this last statement.  Although
>> it can not be implemented using the normal close system call,
>> something should trigger the flush of any dirty pages and wait
>> for them to complete.
>
> This is the way Linux implements dirty mmaps on NFS because that's the 
> way Linus wants it.  I didn't mean to imply that's the way it *should* 
> work, merely the way it *does* work in Linux.

Yes, I recognize that.  That's the way that it worked in Solaris
too, until I decided that it should work differently and implemented
it.

That said, I don't know how hard it would be to sell the new
semantic to Linus.  This may tie in with some other work that
I am doing, so perhaps I will give it a shot.

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
