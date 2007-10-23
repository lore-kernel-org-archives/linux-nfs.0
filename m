From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 00/10] rdma: SVCRDMA Transport Driver
Date: Tue, 23 Oct 2007 14:05:31 -0400
Message-ID: <20071023180531.GF30496@fieldses.org>
References: <20071019215304.31937.28876.stgit@dell3.ogc.int>
	<20071022220219.GW583@fieldses.org>
	<471D5FFD.8090601@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net, gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IkO88-0005FX-SQ
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 11:05:28 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IkO8E-0005RJ-3Q
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 11:05:34 -0700
In-Reply-To: <471D5FFD.8090601@opengridcomputing.com>
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

On Mon, Oct 22, 2007 at 09:44:13PM -0500, Tom Tucker wrote:
> J. Bruce Fields wrote:
>> On Fri, Oct 19, 2007 at 04:53:04PM -0500, Tom Tucker wrote:
>>   
>>> This patchset implements the RDMA Transport Driver for the server 
>>> transport switch. This patchset has been tested with iozone
>>> and Connectathon over NFSv3.     
>>
>> Do you want these applied?
>>
>>   
> Yes. I'm assuming that this would include all incremental patches prior to 
> the RDMA transport driver as well?

Yes; you can check my server-xprt-switch branch to see if I got it all.

>>> This patchset along with all of the previous server side
>>> transport switches are also available in this git tree:
>>>
>>> git://linux-nfs.org/~tomtucker/nfs-rdma-dev-2.6.git
>>>     
>>
>> This is missing a couple changes I made in my version: the two I notice
>> are that I merged both "svc: Don't copy xprt_class data into svc_xprt
>> instance" and "svc: Rename xpo_release to xpo_release_rqst" in with the
>> previous patches.
>>
>>   
> Yes, please. Should I post my subsequent patches relative to your git tree? 
> That might make life easier.

Sure; thanks.

>> So I've ignored that for now and just applied these new patches on top
>> of mine.  I also rebased onto the latest linus git.
>>   
> I should compare your tot to mine to make sure we're not out of sync. I'll 
> do that tomorrow.
>
> FYI, I'm working on a "perfect hindsight" branch as well. I'll let you know 
> when I've got that done.

Oh, OK, fantastic.  I'll stop monkeying with my copy if that's the case.
(Though only exception being that if I may need to rebase every now and
then.)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
