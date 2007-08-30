From: Peter Staubach <staubach@redhat.com>
Subject: Re: mount.nfs: chk_mountpoint()
Date: Thu, 30 Aug 2007 17:11:32 -0400
Message-ID: <46D73284.4090309@redhat.com>
References: <46CC884B.1030207@oracle.com> <46CD82A0.1000408@redhat.com>
	<46CDC7D0.6030803@oracle.com> <46CDD069.3070608@redhat.com>
	<46CDE76C.3040800@oracle.com> <46CDEA2E.10902@redhat.com>
	<20070830101249.GA9880@janus> <46D6AFBC.3000208@redhat.com>
	<46D6E9CF.4000901@oracle.com> <46D6EB44.7050600@redhat.com>
	<46D6EDEE.5060907@oracle.com>
	<EXNANE01okLQ8aZRhQd00000200@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Frank van Maarseveen <frankvm@frankvm.com>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQrId-0000VB-Nj
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 14:11:35 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQrIg-0008J7-Ta
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 14:11:40 -0700
In-Reply-To: <EXNANE01okLQ8aZRhQd00000200@exnane01.hq.netapp.com>
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

Talpey, Thomas wrote:
> At 12:18 PM 8/30/2007, Chuck Lever wrote:
>   
>> Peter Staubach wrote:
>>     
>>> If the application on each client is going to need many mount
>>> points, then how does "bg" do anything but increase the number
>>> of concurrent mount requests coming from each client, thus
>>> increasing the load?
>>>       
>> "bg" has an exponential backoff, so the load increase isn't terribly 
>> bothersome.  It's the "bg" recovery mechanism that's useful here for 
>> getting all the mount requests to be successful in a nondeterministic 
>> environment.
>>     
>
> "bg" also tries synchronously before going into the background (and
> backing off). So, by itself "bg" does not generate a storm. It only
> slightly raises the mount traffic after a failure, by giving way to the
> next filesystem in line - which may well be on another server.
>
> Done right, "bg" is a reasonable approach, IMO.

I will belabor this just a little more and then move on.

Yes, if everything is working correctly, then the "bg" option
adds insignificant overhead and that is in the argument processing
for the mount command.

However, if it backgrounds, there can be multiple mounts
running at the same time.  This could add up to quite a bit
for very many file systems.

And, why are they getting mounted?  Probably not because they
are doing to needed immediately, but because they are being
statically mounted and the only way to do that is via fstab
at mount time.

All of these file systems are sitting, in the namespace,
waiting to cause problems for applications looking at the
namespace if the slightest problem occurs out on the network
or at one of the servers which was mounted from.  They add
overhead to applications which do look at the namespace in
the meantime because they add to the number of file systems
that these applications need to keep track of.

I wish that I had a nickel for each time that I heard a
customer complain because some dead server caused his
application or the df command to hang and he wasn't
interested in that server.  I'd be retired and typing this
from some fun location.  :-)

Oh well, "bg" is a solution, but I think that there are better.

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
