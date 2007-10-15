From: Andrea Righi <righiandr@users.sourceforge.net>
Subject: Re: nfsd closes port 2049
Date: Mon, 15 Oct 2007 23:57:47 +0200 (MEST)
Message-ID: <4713E25D.6090302@users.sourceforge.net>
References: <47139C02.9020009@cineca.it>
	<18195.52347.544844.155538@notabene.brown>
Reply-To: righiandr@users.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, LKML <linux-kernel@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IhXwg-0001co-6c
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 14:57:54 -0700
Received: from as3.cineca.com ([130.186.84.211])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IhXwk-0004yu-9v
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 14:57:59 -0700
In-Reply-To: <18195.52347.544844.155538@notabene.brown>
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

Neil Brown wrote:
> On Monday October 15, a.righi@cineca.it wrote:
>> Hi all,
>>
>> I'm trying to debug a weird problem with nfsd on a 2.6.16.27-0.6-smp
>> kernel.
>>
>> 1 server: SuSE SLES 10 x86_64, config attached
>> 256 clients: RHEL4 Update 4 2.6.9-42.ELsmp x86_64
>>
>> Using nfs v3.
>>
>> The clients have been happily talking to the server for several days
>> without incident.
>>
>> The weird thing is that at a certain point the socket opened on port
>> 2049 on the NFS server is being closed for unknown reasons (or better
>> for unknown reasons for me!).
> 
> This is fixed in any release based on 2.6.16.31 or later.
> The relevant mainline patch is 
>     1a047060a99f274a7c52cfea8159e4142a14b8a7
> as below.
> So update your kernel package.

Thanks Neil, looking at the source and in my logs this seems to explain
perfectly my problem. I'll try the patch ASAP.

-Andrea

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
