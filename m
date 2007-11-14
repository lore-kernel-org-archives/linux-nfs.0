From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 00/25] RFC: AF_INET6 family support for the NFS
	client
Date: Wed, 14 Nov 2007 08:26:05 -0500
Message-ID: <6E3A8C73-D31F-4FE5-9389-37DF052C1154@oracle.com>
References: <20071113182226.5087.77009.stgit@manray.1015granger.net>
	<20071113.171424.267123659.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org, nfs@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsIGb-0001Vp-Aj
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 05:26:53 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IsIGf-0000jF-S6
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 05:26:59 -0800
In-Reply-To: <20071113.171424.267123659.davem@davemloft.net>
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

On Nov 13, 2007, at 8:14 PM, David Miller wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> Date: Tue, 13 Nov 2007 13:30:59 -0500
>
>> These 25 patches add support for AF_INET6 addresses to the NFS  
>> client.
>> This is a request for review of the proposed changes.
>
> Please start using the linux-nfs@vger.kernel.org mailing list
> for future submissions instead of the sourceforge one.
>
> Thank you.

Hi David-

Neil Brown has discussed a transition plan.  There were no objections  
to moving to vger, but we don't have a timeframe yet.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
