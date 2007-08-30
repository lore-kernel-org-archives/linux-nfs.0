From: Peter Staubach <staubach@redhat.com>
Subject: Re: mount.nfs: chk_mountpoint()
Date: Thu, 30 Aug 2007 12:07:32 -0400
Message-ID: <46D6EB44.7050600@redhat.com>
References: <46CC884B.1030207@oracle.com> <46CD82A0.1000408@redhat.com>
	<46CDC7D0.6030803@oracle.com> <46CDD069.3070608@redhat.com>
	<46CDE76C.3040800@oracle.com> <46CDEA2E.10902@redhat.com>
	<20070830101249.GA9880@janus> <46D6AFBC.3000208@redhat.com>
	<46D6E9CF.4000901@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Frank van Maarseveen <frankvm@frankvm.com>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQmYU-0003Ci-QC
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 09:07:39 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQmYY-000800-VE
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 09:07:43 -0700
In-Reply-To: <46D6E9CF.4000901@oracle.com>
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
>> Frank van Maarseveen wrote:
>>> On Thu, Aug 23, 2007 at 04:12:30PM -0400, Peter Staubach wrote:
>>>  
>>>> I would guess that not so many people are using the "bg" option,
>>>> period.  Many of Linux's customers are ex-Sun customers and they
>>>> were educated to use autofs and to move away from and stay away
>>>> from static mounts via fstab or vfstab.
>>>>
>>>> The "bg" option was a hack added to speed up system booting.
>>>>     
>>>
>>> No, it is indispensable to recover properly from a power outage:
>>> servers tend to boot slower than clients. Also, it is not unusual to
>>> have some minor network/server problems after an outage causing the
>>> mount to fail.
>>>
>>> Without the bg option a temporary power outage may render all client
>>> systems unusable.
>>
>> And a better solution to this problem is still to use autofs.
>>
>> That said, what use are the clients _until_ the servers are up?
>> The applications on them can't run correctly because the file
>> systems that they depend upon may or may not be there yet.  With
>> autofs, you would have a chance of getting the synchronization
>> right.
>>
>> You also get all sorts of benefits such as decreased resource
>> usage (by not having inactive file systems mounted), reduced
>> hangs (by not having inactive file systems from servers which
>> go down still mounted), in addition to the situation described
>> above and other benefits as well.
>>
>> I do recognize that we can't get rid of the bg option, but I
>> would request that people using it consider different alternatives
>> to solving their problems.
>
> For the record, one downside to using automounter is the mount storm 
> that is caused when a distributed application starts up on multiple 
> clients requiring many NFS mount points on each client.  This is one 
> reason some sites choose not to use automounter.  "bg"s retry 
> behavior, though a kludge, is somewhat more friendly.
>

If the application on each client is going to need many mount
points, then how does "bg" do anything but increase the number
of concurrent mount requests coming from each client, thus
increasing the load?

Autofs supporting dynamic mounting of individual file systems
within a hierarchy would help to reduce the overhead on the
network and server as much as seems possible to me...

I suspect that this is on Ian's and Jeff's lists...  :-)

> From my experience, generally mountd (on most any server 
> implementation) has been a scalability problem in these scenarios.  It 
> can't handle more than a few requests per second.

Perhaps we need to look at multithreading mountd?  Ala Solaris?

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
