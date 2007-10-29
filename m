From: Huang Xiong <huangxiong@uit.com.cn>
Subject: How to specify sctp protocol?
Date: Mon, 29 Oct 2007 17:46:15 +0800
Message-ID: <200710291746.15411.huangxiong@uit.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ImREA-0001OB-B7
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 02:48:10 -0700
Received: from [211.154.174.66] (helo=uit.com.cn)
	by mail.sourceforge.net with smtp (Exim 4.44) id 1ImREA-0003Rv-SL
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 02:48:16 -0700
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

Hello folks,

As NFSv4 supports SCTP protocol,  how to specify this protocol in application?
or need to add some option appened with mount the NFS shares?

My underlying filesystem is GFS, which uses SCTP for cluster internode 
communication. I wonder that I have to specify the SCTP option when I try to 
mount NFS share based on GFS.

I've been trying to find some useful information but with no success.
Anyone having an idea or experienced the same problem?
Maybe I can provide more useful information on this.

Thanks in advance.
Phillip 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
