From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH] svc: Fix the UDP address logic
Date: Mon, 22 Oct 2007 21:13:20 -0500
Message-ID: <471D58C0.1090707@opengridcomputing.com>
References: <20071022210148.9997.94538.stgit@dell3.ogc.int>
	<20071023015329.GA6354@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ik9Gs-0000ci-Vc
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 19:13:31 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ik9Gy-0005Dq-9a
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 19:13:36 -0700
In-Reply-To: <20071023015329.GA6354@sgi.com>
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

Greg Banks wrote:
> On Mon, Oct 22, 2007 at 04:01:48PM -0500, Tom Tucker wrote:
>   
>> When the address information was moved to the svc_xprt structure, a bug
>> was introduced to UDP that caused an incorrect address to be used
>> when responding to RPC on the UDP transport. This was the result of
>> failing to completely implement the generic address logic for the UDP 
>> transport.
>>     
>
> ok.
>
>   
>> Since I confused myself, it's probably a good idea to describe how 
>> this is supposed to work. [...]
>>     
>
> This is useful text, any chance you can put it into a comment
> or a text file describing the xprt switch interface?
>
>   
I think it would be most useful if I wrote a document  describing the 
transport switch and the requirements of a transport driver. The text 
file would be for the Documentation directory. I'll try to get to it in 
the next week.
> Greg.
>   


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
