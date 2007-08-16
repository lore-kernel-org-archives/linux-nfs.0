From: Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>
Subject: Re: [PATCH] unfsd: fix invalid argument error for setattr
 request
Date: Thu, 16 Aug 2007 16:51:01 +0900
Message-ID: <200708160751.AA00238@paprika.lab.ntt.co.jp>
References: <Pine.LNX.4.64.0708160843060.10107@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Peter_Astrand <astrand@cendio.se>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILa8i-0002nN-IV
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 00:51:32 -0700
Received: from tama5.ecl.ntt.co.jp ([129.60.39.102])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ILa8l-0007Gd-Gc
	for nfs@lists.sourceforge.net; Thu, 16 Aug 2007 00:51:36 -0700
In-Reply-To: <Pine.LNX.4.64.0708160843060.10107@maggie.lkpg.cendio.se>
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

Hi,

On Thu, 16 Aug 2007, Peter_Astrand wrote:
>On Thu, 16 Aug 2007, Ryusuke Konishi wrote:
>> Hi folks, 
>> 
>> I found that the Linux user-space NFS server (unfsd) fails
>> for setattr requests against the kernel 2.6.22 and later.
>
>Hi, I'm curious: Why are you using this old unfsd instead of the kernel 
>based knfsd, or the modern userspace implementation "unfs3"?

I am using both unfsd and knfsd because Debian still offers both.
(It also offers unfs3 but I didn't notice until you let me know)

>As far as I understand, noone is maintaining the old unfsd anymore. 
>
>
>Regards, 

All right.
As you say, the mail to unfsd maintainers was returned by
Host unknown. (Sigh)
It seems to have little hope to modify unfsd for this. 

Thanks,
Ryusuke Konishi

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
