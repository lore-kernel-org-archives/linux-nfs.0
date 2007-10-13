From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 0/3] svc: gnb review cleanup for transport switch
Date: Sat, 13 Oct 2007 07:35:21 -0500
Message-ID: <C33625B9.3C913%tom@opengridcomputing.com>
References: <20071013034842.GA13453@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Greg Banks <gnb@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Igg4w-0003U6-Vi
	for nfs@lists.sourceforge.net; Sat, 13 Oct 2007 05:26:51 -0700
Received: from mail.hotelhsiamail.com ([12.36.131.43])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Igg51-00083u-4H
	for nfs@lists.sourceforge.net; Sat, 13 Oct 2007 05:26:56 -0700
In-Reply-To: <20071013034842.GA13453@fieldses.org>
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


On 10/12/07 10:48 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Oct 12, 2007 at 06:30:00PM -0400, bfields wrote:
>> On Fri, Oct 12, 2007 at 06:03:00PM -0400, bfields wrote:
>>> Sorry, yes, it's currently in "master" in my git tree:
>>> 
>>> git://linux-nfs.org/~bfields/linux.git master
>>> 
>>> I believe it's got everything you've sent me so far except the three
>>> patches from today.  I haven't looked at it again since yesterday.
>> 
>> Bah, don't spend any time on this.  I took another look, and it seems
>> the problem is in the exported filesystem itself, not in the server.
> 
> Yeah, there were some filesystem errors in the logs, and after
> reformatting that partition I can't reproduce the problem.  I think that
> one machine may just have an unreliable drive.
>

No worries, I found three other bugs in the process :-)

Tom 
> --b.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
