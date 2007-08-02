From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Status of mount.nfs
Date: Thu, 02 Aug 2007 17:43:06 -0400
Message-ID: <46B24FEA.1040300@oracle.com>
References: <20070708191640.GA13962@uio.no>	
	<18065.43199.104020.412029@notabene.brown>	<20070715083114.GB4158@uio.no>	
	<18074.50730.591965.39211@notabene.brown>	<20070716092047.GA10353@uio.no>	
	<18075.17719.855332.259470@notabene.brown>	<20070722191733.GA31501@uio.no>	
	<46A52816.6050500@oracle.com>	<20070724172451.GA14026@uio.no>	
	<46A7A5F8.4040204@oracle.com>	<46A897CD.50201@RedHat.com>	
	<46A96032.7080503@oracle.com>	<46AA089E.50503@RedHat.com>	
	<1185551769.6586.28.camel@localhost>	<46AA1A70.5010705@RedHat.com>	
	<1185553679.6586.34.camel@localhost>	<46AA2642.60505@RedHat.com>	
	<1185556406.6586.45.camel@localhost>	<46AB3BE9.1060903@RedHat.com>	
	<1185906627.6700.30.camel@localhost>
	<46AFA98E.1070904@oracle.com>	 <46B0674D.7000803@RedHat.com>
	<46B0E6DC.4080409@oracle.com>	 <46B0F747.3050704@RedHat.com>
	<46B20467.5050601@oracle.com> <1186080125.27480.10.camel@localhost>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000602090602080002030701"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGiT9-00088l-RR
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 14:44:34 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGiTC-0000aD-L8
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 14:44:36 -0700
In-Reply-To: <1186080125.27480.10.camel@localhost>
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

This is a multi-part message in MIME format.
--------------000602090602080002030701
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Thu, 2007-08-02 at 12:20 -0400, Chuck Lever wrote:
> 
>> I'm not suggesting that we don't support mounting through a firewall. 
>> I'm wondering, though, how people expect it to work.  Is it acceptable 
>> to require a few extra mount options on clients to mount successfully 
>> through a firewall, or should a mount with no options whatsoever always 
>> work in this case?
> 
> The strategy should be to make the _default_ behaviour safe. If you want
> to add optimisations that need switching on/off then those may take
> extra mount options.

Exactly: is mounting through a firewall an optimization, or is it 
something that users expect, by default, to work without using extra 
options?

--------------000602090602080002030701
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------000602090602080002030701
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------000602090602080002030701
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000602090602080002030701--
