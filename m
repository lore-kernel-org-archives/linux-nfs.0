From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [RFC] NLM lock failover admin interface
Date: Thu, 15 Jun 2006 14:43:50 -0400
Message-ID: <4491AA66.2050900@redhat.com>
References: <1150089943.26019.18.camel@localhost.localdomain>	<17550.11870.186706.36949@cse.unsw.edu.au>	<1150268091.28264.75.camel@localhost.localdomain>	<17552.57749.121240.42384@cse.unsw.edu.au>	<1150353564.4566.89.camel@localhost.localdomain>
	<17553.5160.366425.740082@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux clustering <linux-cluster@redhat.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fqwp7-00064O-Kk
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 11:44:09 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fqwp6-0006ja-FU
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 11:44:09 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17553.5160.366425.740082@cse.unsw.edu.au>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Neil Brown wrote:

>Could you please explain to me what "active-active failover for local
>filesystem such as ext3" means 
>
Clustering is a profilic subject so the term may mean different things 
to different people. The setup we discuss here is to move an NFS service 
from one server to the other while both servers are up and running 
(active-active). The goal is not to disturb other NFS services that are 
not involved with the transition.

>It sounds like the filesystem is active on two nodes at once, which of
>course cannot work for ext3, so I am confused.
>And if you are doing "failover", what has failed?
>
>The load-balancing scenario makes sense (at least so far...).
>  
>
Local filesystem such as ext3 will never be mounted on more than two 
nodes but cluster filesystems (e.g. our GFS) will. Moving ext3 normally 
implies error conditions (a true failover) though in rare cases, it may 
be kicked off for load balancing purpose. Current GFS locking has the 
"node-id" concept - the easiest way (at this moment) for virtual IP to 
float around is to drop the locks and let NLM reclaim the locks from the 
new server.

>
>Our two export flags mean VERY different things.
>Mine says 'locks against this export are per-server-ip-address'.
>Yours says (I think) 'remove all lockd locks from this export' and is
>really an unexport flag, not an export flag.
>
>And this makes it not really workable.  We no-longer require the user
>of the nfssvc syscall to unexport filesystems.  Infact nfs-utils doesn't
>use it at all if /proc/fs/nfsd is mounted.  filesystems are unexported
>by their entry in the export cache expiring, or the cache being
>flushed.
>  
>
The important thing (for me) is the vfsmount reference count which can 
only be properly decreased when unexport is triggered. Without 
decreasing the vfsmount, ext3 can not be un-mounted (and we need to 
umount ext3 upon failover). I havn't looked into community versions of 
kernel source for a while (but I'll check). So what can I do to ensure 
this will happen ? - i.e., after the filesystem has been accessed by 
nfsd, how can I safely un-mount it without shuting down nfsd (and/or 
lockd) ?   

>'struct nlm_file' is a structure that is entirely local to lockd.
>It does not feature in any of the interface between lockd and any
>other part of the kernel.  It is not part of any credible KABI.
>The other changes I suggest involve adding an exported symbol to
>lockd, which does change the KABI but in a completely back-compatible
>way, and re-interpreting the return value of a callout.  
>That could not break any external module - it could only break
>someone's setup if they had an alternate lockd module, but I don't
>your KABI policy allows people to replace modules and stay supported,
>  
>
Yes, you're right ! I looked into the wrong code (well, it was late in 
the night so I was not very functional at that moment). Had some 
prototype code where I transported the nlm_file from one server to 
another server , experimenting auto-reclaiming locks without stated. I 
exported the nlm_file list there. So let's forget about this 

>>>>>  One is the multiple-lockd-threads idea.
>>>>>          
>>>>>
>>>I'm losing interest in the multiple-lockd-threads approach myself (for
>>>the moment anyway :-)
>>>      
>>>
Good! because I'm not sure whether we'll hit scalibility issue or not 
(100 nfs services implies 100 lockd threads !).

>>>However I would be against trying to re-use rpc.lockd - that was a
>>>mistake that is best forgotten.
>>>      
>>>
Highlight this :) ... Give me some comfort feelings that I'm not the 
only person who would make mistakes.

>>>If the above approach were taken, then I don't think you need anything
>>>more than
>>>   echo aa.bb.cc.dd > /proc/fs/nfsd/vserver_unlock
>>>(or whatever), though it you really want to wrap that in a shell
>>>script that might be ok.
>>>      
>>>
>>This is funny - so we go back to /proc. OK with me :)
>>    
>>
>
>Only sort-of back to /proc.  /proc/fs/nfsd is a separate filesystem
>which happens to be mounted there normally.
>The unexport system call goes through this exact same filesystem
>(though it is somewhat under-the-hood) so at that level, we are
>really propose the same style of interface implementation.
>  
>
>>But again, I'm OK with /proc approach. However, with /proc approach, we
>>may need socket address (since not every export uses fsid and devno is
>>not easy to get).
>>    
>>
>
>Absolutely. We need a socket address.  
>As part of this process you are shutting down an interface.  We know
>(or can easily discover) the address of that interface.  That is
>exactly the address that we feed to nfsd.
>  
>
Now, it looks good ! Will do the following:
 
1. Futher understand the steps to make sure we can un-mount ext3 due to 
"unexport" method changes.
2. Start to code to the /proc interface and make sure "rpc.stated -H"can 
work (lock reclaiming needs it). Will keep NFS v4 in mind as well.

By the way, there is a socket state-change-handler (TCP only) and/or 
network interface notification routine that seem to be workable (your 
previous thoughts). However, I don't plan to keep exploring that 
possibility since we now have a simple and workable method in place.

-- Wendy







_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
