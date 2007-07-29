From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Status of mount.nfs
Date: Sun, 29 Jul 2007 15:24:01 -0400
Message-ID: <46ACE951.60806@RedHat.com>
References: <20070708191640.GA13962@uio.no>	<18065.43199.104020.412029@notabene.brown>	<20070715083114.GB4158@uio.no>	<18074.50730.591965.39211@notabene.brown>	<20070716092047.GA10353@uio.no>	<18075.17719.855332.259470@notabene.brown>	<20070722191733.GA31501@uio.no>
	<46A52816.6050500@oracle.com>	<20070724172451.GA14026@uio.no>
	<46A7A5F8.4040204@oracle.com> <46A897CD.50201@RedHat.com>
	<46A96032.7080503@oracle.com> <46AA089E.50503@RedHat.com>
	<46AA4989.8040003@oracle.com> <46AB4290.4090408@RedHat.com>
	<46ABAE5F.1000208@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFEOL-0007ZU-5n
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 12:25:25 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IFEON-0000FW-PN
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 12:25:29 -0700
In-Reply-To: <46ABAE5F.1000208@oracle.com>
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
>>> umount.nfs uses getmntdirbackward(), which probes /etc/mtab, as far 
>>> as I can tell.  One problem with this is that often the effective 
>>> transport protocol isn't listed in /etc/mtab at all, if, say, the 
>>> user requests TCP and the server supports only UDP.
>> This got lost in the translation... In older mount code (i.e. the one
>> in utils-linux) /proc/mounts is used which is a much simpler way
>> of dealing with this... imho..
> 
> Miklos seems intent on eliminating /etc/mtab anyway...
Good...

> 
>>> I can't see why we need to refer back to either file to determine the 
>>> transport protocol for a umount request.  Whatever transport mountd 
>>> is advertising at the moment is what should be used, right?
>> Well for firewall reasons you generally want to use the protocol
>> that the mount used...
> 
> That could have been a very long time ago, even months, and the server 
> settings may have changed.  Thus sending what mount used seems 
> inherently unreliable.  The race window is enormous!
hmm... I must be missing something... Why is umount-ing with the
same network protocol that mount used unreliable and racy?

> 
>>> [ Steve, since you have a different recollection of how all this 
>>> mount stuff works, I wonder if Amit took an older version of mount 
>>> when he split out the new mount.nfs helper... Can you verify this?  
>>> Maybe there are some fixes you made that need to be ported over. ]
>> No... I pretty sure I had Amit use the latest and greatest...
>> I just think there was some decisions made or liberties taken
>> without a complete understand of what the ramification were...
> 
> Thanks for checking on this.  I worried we may have missed some 
> important bug fixes.
A while back I did a patch dump of all the bugs we found when
we added the new code to Fedora... Neil's tree has all the patch
we have..


> Well, if libtirpc is added to nfs-utils, the mount command could use 
> that instead.  We'd be able to fix any bugs in libtirpc quite easily. 
> That seems like an excellent way to address every problem with glibc's 
> RPC implementation, and immediately have a "simple" use case for testing 
> libtirpc (or whatever we have to replace the RPC functionality in glibc).
I can't agree with you more... At this point both rpcbind and libtirpc
are now fully supported by both Bull and yours truly... Both
tarballs are available on sourceforge:

     http://sourceforge.net/projects/libtirpc/
     http://sourceforge.net/projects/rpcbind/
Git trees are at:
     http://git.infradead.org/?p=users/steved/libtirpc.git
     http://git.infradead.org/?p=users/steved/rpcbind.git

And of course the rpms are available from Fedora mirrors

At this point everything is not quite synced up but that
will change very shortly... and new release will be coming
because the code is being used and bugs are being fixed...

The next major step would be to port nfs-utils to use libtirpc
which is on my todo list along with a ton of other things... :-\

In the end, I think it would be a very good move for our community
to own the entire stack... including the RPC library code...

steved.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
