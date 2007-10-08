From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: meaning of /proc/net/rpc/nfsd
Date: Mon, 8 Oct 2007 10:56:51 -0400
Message-ID: <20071008145651.GD2902@fieldses.org>
References: <4709F4FD.8010103@cesca.es> <20071008142428.GB2902@fieldses.org>
	<470A43B1.4040006@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ieu2X-0006g4-Cd
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 07:57:01 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ieu2a-00059M-BQ
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 07:57:06 -0700
In-Reply-To: <470A43B1.4040006@oracle.com>
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

On Mon, Oct 08, 2007 at 10:50:25AM -0400, Chuck Lever wrote:
> J. Bruce Fields wrote:
>> On Mon, Oct 08, 2007 at 11:14:37AM +0200, Jordi Prats wrote:
>>> Hi all,
>>> I don't know if this is the correct list. I'd like to know what does the 
>>> contents of /proc/net/rpc/nfsd mean.
>
> I believe /proc/net/rpc/nfsd is documented in the Linux NFS How-To, located 
> here:
>
>   http://nfs.sourceforge.net

There's a short explanation of the one "th" line in B1, but that's all I
see.

--b.

>
>>> I've been googling for a while but I found nothing but this message:
>>>
>>> http://marc.info/?l=linux-nfs&m=102824853219024&w=2
>>>
>>>  From this message I can suppose what mean the th line, but nothing about 
>>> the others? Where can I read some documentation about the contents of 
>>> this file?
>> The only real documentation right now is the code, I think; start
>> reading at net/sunrpc/stats.c:nfsd_proc_show().  Some documentation
>> would be great, I agree; patches welcomed....
>

> begin:vcard
> fn:Chuck Lever
> n:Lever;Chuck
> org:Oracle Corporation;Corporate Architecture: Linux Projects Group
> adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
> title:Principal Member of Staff
> tel;work:+1 248 614 5091
> x-mozilla-html:FALSE
> version:2.1
> end:vcard
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
