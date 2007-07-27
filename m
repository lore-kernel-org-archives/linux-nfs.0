From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Status of mount.nfs
Date: Fri, 27 Jul 2007 17:38:45 -0400
Message-ID: <46AA65E5.4070003@oracle.com>
References: <20070708191640.GA13962@uio.no>	<18065.43199.104020.412029@notabene.brown>	<20070715083114.GB4158@uio.no>	<18074.50730.591965.39211@notabene.brown>	<20070716092047.GA10353@uio.no>	<18075.17719.855332.259470@notabene.brown>	<20070722191733.GA31501@uio.no>	<46A52816.6050500@oracle.com>	<20070724172451.GA14026@uio.no>	<46A7A5F8.4040204@oracle.com>
	<46A897CD.50201@RedHat.com>	<46A96032.7080503@oracle.com>
	<46AA089E.50503@RedHat.com>	<1185551769.6586.28.camel@localhost>
	<46AA1A70.5010705@RedHat.com>	<1185553679.6586.34.camel@localhost>
	<46AA2642.60505@RedHat.com> <1185556406.6586.45.camel@localhost>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080407000602080900070600"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEXWz-0008RK-Gr
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 14:39:29 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IEXX1-0003Es-Tk
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 14:39:33 -0700
In-Reply-To: <1185556406.6586.45.camel@localhost>
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
--------------080407000602080900070600
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:
> On Fri, 2007-07-27 at 13:07 -0400, Steve Dickson wrote:
> 
>> After how long of a wait? If all the timeouts are controllable then
>> I agrees, but if we have to wait undefined-able amount of time for
>> every RPC retransmit, then I think we should do a ping...
> 
> You should be able to set the timeout either on a per-RPC call basis by
> using clnt_call(), or by changing the default timeout on the CLIENT
> object using clnt_control() (man 3 rpc).

The mount command uses a "standard" timeout structure to set a 25 second 
timeout for both UDP and TCP, but I've noticed that TCP connections for 
most RPC requests from the mount command to unavailable servers appear 
to hang indefinitely.  I'll take a look at this.

--------------080407000602080900070600
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
version:2.1
end:vcard


--------------080407000602080900070600
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------080407000602080900070600
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080407000602080900070600--
