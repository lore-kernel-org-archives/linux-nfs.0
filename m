From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nfsd closes port 2049
Date: Tue, 16 Oct 2007 08:10:30 -0400
Message-ID: <EXNANE014r3mbfJ8VrR0000070e@exnane01.hq.netapp.com>
References: <47139C02.9020009@cineca.it>
	<18195.52347.544844.155538@notabene.brown>
	<4713E25D.6090302@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: righiandr@users.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IhlGc-0007Bm-4w
	for nfs@lists.sourceforge.net; Tue, 16 Oct 2007 05:11:25 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IhlGg-0004pV-Ci
	for nfs@lists.sourceforge.net; Tue, 16 Oct 2007 05:11:27 -0700
In-Reply-To: <4713E25D.6090302@users.sourceforge.net>
References: <47139C02.9020009@cineca.it>
	<18195.52347.544844.155538@notabene.brown>
	<4713E25D.6090302@users.sourceforge.net>
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

At 05:57 PM 10/15/2007, Andrea Righi wrote:
>Neil Brown wrote:
>>> The weird thing is that at a certain point the socket opened on port
>>> 2049 on the NFS server is being closed for unknown reasons (or better
>>> for unknown reasons for me!).
>> 
>> This is fixed in any release based on 2.6.16.31 or later.
>> The relevant mainline patch is 
>>     1a047060a99f274a7c52cfea8159e4142a14b8a7
>> as below.
>> So update your kernel package.
>
>Thanks Neil, looking at the source and in my logs this seems to explain
>perfectly my problem. I'll try the patch ASAP.

BTW, the nfsd_acceptable() issue is different from this one, and the
no_subtree_check I suggested may still be needed (right Neil?). I'm
interested in what you find - keep us posted.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
