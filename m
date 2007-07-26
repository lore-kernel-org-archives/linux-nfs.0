From: Simon Gao <gao@schrodinger.com>
Subject: Re: Autofs failed auto umounting NFS shares exported by
 Solaris 10
Date: Thu, 26 Jul 2007 10:25:18 -0700
Message-ID: <46A8D8FE.8010406@schrodinger.com>
References: <46A57CFA.2010507@schrodinger.com>
	<Pine.LNX.4.64.0707262135460.22065@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Ian Kent <raven@themaw.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IE75q-0006IR-3g
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 10:25:42 -0700
Received: from thermidore.schrodinger.com ([192.156.98.99]
	helo=schrodinger.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1IE75s-000232-Er
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 10:25:46 -0700
In-Reply-To: <Pine.LNX.4.64.0707262135460.22065@raven.themaw.net>
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

Ian Kent wrote:
> On Mon, 23 Jul 2007, Simon Gao wrote:
>
>   
>> Hi,
>>
>> I am seeing RHEL/CentOS 5.0 machine failed to un-mount NFS share 
>> exported by Solaris 10 after time out period:
>>     
>
> How about providing a debug log?
> See http://people.redhat.com/jmoyer for what we need.
> What is the kernel version?
>
> btw, the autofs list is probably a better place for this to be discussed.
> It can be found at http://linux.kernel.org/mailman/listinfo/autofs.
>   
1. autofs version:      autofs-5.0.1-0.rc2.43.0.2
2. kernel version:      2.6.18-8.1.8.el5xen

Thanks for the pointer.  I am collecting debug log. Once it's ready, I 
will submit the log.

Simon

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
