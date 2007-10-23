From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 00/10] rdma: SVCRDMA Transport Driver
Date: Mon, 22 Oct 2007 21:44:13 -0500
Message-ID: <471D5FFD.8090601@opengridcomputing.com>
References: <20071019215304.31937.28876.stgit@dell3.ogc.int>
	<20071022220219.GW583@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net, gnb@sgi.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ik9kl-0003W9-G5
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 19:44:23 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ik9kq-0005PF-Rp
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 19:44:29 -0700
In-Reply-To: <20071022220219.GW583@fieldses.org>
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

J. Bruce Fields wrote:
> On Fri, Oct 19, 2007 at 04:53:04PM -0500, Tom Tucker wrote:
>   
>> This patchset implements the RDMA Transport Driver for the 
>> server transport switch. This patchset has been tested with iozone
>> and Connectathon over NFSv3. 
>>     
>
> Do you want these applied?
>
>   
Yes. I'm assuming that this would include all incremental patches prior 
to the RDMA transport driver as well?
>> This patchset along with all of the previous server side
>> transport switches are also available in this git tree:
>>
>> git://linux-nfs.org/~tomtucker/nfs-rdma-dev-2.6.git
>>     
>
> This is missing a couple changes I made in my version: the two I notice
> are that I merged both "svc: Don't copy xprt_class data into svc_xprt
> instance" and "svc: Rename xpo_release to xpo_release_rqst" in with the
> previous patches.
>
>   
Yes, please. Should I post my subsequent patches relative to your git 
tree? That might make life easier.
> So I've ignored that for now and just applied these new patches on top
> of mine.  I also rebased onto the latest linus git.
>   
I should compare your tot to mine to make sure we're not out of sync. 
I'll do that tomorrow.

FYI, I'm working on a "perfect hindsight" branch as well. I'll let you 
know when I've got that done.
> Also, there's still that small sysctl complaint from Andrew outstanding,
> which I haven't had the time to look into.
>
>   

> --b.
>   



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
