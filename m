From: "Iyer, Rahul" <Rahul.Iyer@netapp.com>
Subject: Re: How to specify sctp protocol?
Date: Mon, 29 Oct 2007 02:59:01 -0700
Message-ID: <7619F3097FAB384287CF636FF92D0CA10B605CDB@exsvl01.hq.netapp.com>
References: <200710291746.15411.huangxiong@uit.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "Huang Xiong" <huangxiong@uit.com.cn>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ImRQk-0002gC-1s
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 03:01:10 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ImRQo-00088d-Et
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 03:01:15 -0700
In-Reply-To: <200710291746.15411.huangxiong@uit.com.cn>
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

I don't believe you can. I don't think NFS over SCTP is supported yet.
-Rahul
 

> -----Original Message-----
> From: Huang Xiong [mailto:huangxiong@uit.com.cn] 
> Sent: Monday, October 29, 2007 3:16 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] How to specify sctp protocol?
> 
> Hello folks,
> 
> As NFSv4 supports SCTP protocol,  how to specify this 
> protocol in application?
> or need to add some option appened with mount the NFS shares?
> 
> My underlying filesystem is GFS, which uses SCTP for cluster 
> internode communication. I wonder that I have to specify the 
> SCTP option when I try to mount NFS share based on GFS.
> 
> I've been trying to find some useful information but with no success.
> Anyone having an idea or experienced the same problem?
> Maybe I can provide more useful information on this.
> 
> Thanks in advance.
> Phillip 
> 
> --------------------------------------------------------------
> -----------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and 
> a browser.
> Download your FREE copy of Splunk now >> 
> http://get.splunk.com/ _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net 
> https://lists.sourceforge.net/lists/listinfo/nfs
> 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
