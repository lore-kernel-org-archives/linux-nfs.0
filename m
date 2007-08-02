From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Status of mount.nfs
Date: Thu, 02 Aug 2007 12:20:55 -0400
Message-ID: <46B20467.5050601@oracle.com>
References: <20070708191640.GA13962@uio.no>	<18065.43199.104020.412029@notabene.brown>	<20070715083114.GB4158@uio.no>	<18074.50730.591965.39211@notabene.brown>	<20070716092047.GA10353@uio.no>	<18075.17719.855332.259470@notabene.brown>	<20070722191733.GA31501@uio.no>	<46A52816.6050500@oracle.com>	<20070724172451.GA14026@uio.no>	<46A7A5F8.4040204@oracle.com>	<46A897CD.50201@RedHat.com>	<46A96032.7080503@oracle.com>	<46AA089E.50503@RedHat.com>	<1185551769.6586.28.camel@localhost>	<46AA1A70.5010705@RedHat.com>	<1185553679.6586.34.camel@localhost>	<46AA2642.60505@RedHat.com>	<1185556406.6586.45.camel@localhost>	<46AB3BE9.1060903@RedHat.com>
	<1185906627.6700.30.camel@localhost>
	<46AFA98E.1070904@oracle.com> <46B0674D.7000803@RedHat.com>
	<46B0E6DC.4080409@oracle.com> <46B0F747.3050704@RedHat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020607070101060005060704"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGdQL-0005oU-Lt
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 09:21:17 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGdQO-0000Hk-8o
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 09:21:21 -0700
In-Reply-To: <46B0F747.3050704@RedHat.com>
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
--------------020607070101060005060704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:
> Chuck Lever wrote:
>> Steve Dickson wrote:
>>> Chuck Lever wrote:
>>>> I was looking at this yesterday.  The stock timeout for TCP connects 
>>>> on Linux is 75 seconds.  The version of getport() used in the mount 
>>>> command might control the TCP connect timeout by using a 
>>>> non-blocking connect() with a select().  The select() then times out 
>>>> if the connection doesn't complete.
>>>>
>>>> But I'm wondering if we really want to continue using TCP for 
>>>> GETPORT calls.  Solaris mount appears to use only UDP for GETPORT, 
>>>> for example.
>>
>>> As as long as the GETPORTs don't use privilege ports I don't think its
>>> a problem...
>>
>> Not sure what you mean.  Yesterday you said the TCP connect timeout 
>> *was* a problem.  I've recommended two ways to address it.
> TCP timeouts are a problem if you can't control them... But
> point taken... UPD is probably the best way to query a
> portmapper or rpcbinder to get the needed info...

OK, I have a patch that shortens the TCP connect timeout for mount.nfs. 
  Will post a follow-up; please take a look.

>> The ephemeral port space is limited too, don't forget.  It's simply a 
>> somewhat larger space than the privileged port space.  If a large 
>> network application (say, a web server) is running on the system, that 
>> space can shrink fairly rapidly, and we're in nearly the same boat as 
>> with privileged ports.  Using a TCP connection from an ephemeral port 
>> only mitigates the port space problem, it doesn't really correct it 
>> entirely.
> Only mitigates the problem for a short time and you'll always run
> out of privileged port before running out of non-privileged but
> again... point taken... eliminating the problem is probably
> the answer...

Yes, and you've suggested a mount connection cache to help with this... 
that might be something reasonable to try in the kernel mount 
implementation at some point.

>> We say "firewall!" a lot, but I would like to see typical use cases 
>> for mounting through a firewall so I understand what kind of 
>> implementation we're aiming for (and maybe even what kind of test 
>> cases to build!).  Do our users really expect to mount NFS shares 
>> through any firewall with "-o defaults" ?
> Yes! Mostly on the server side... meaning people wanted to set the
> port the daemons listen on (via the initscripts) so clients can
> access the server through a firewall... Is this a common setup?
> No. But there are people that want a firewall between the
> server and client..

I'm not suggesting that we don't support mounting through a firewall. 
I'm wondering, though, how people expect it to work.  Is it acceptable 
to require a few extra mount options on clients to mount successfully 
through a firewall, or should a mount with no options whatsoever always 
work in this case?

And, does anyone have real and precise test cases to make sure we don't 
break mounting through a firewall when changes are made to the mount 
infrastructure?

> Also I can only assume the reason for the
> 'mountport=" option was to work better with firewalls...
> but that is only speculation...

I agree that the mount{prog,vers,port}= options are very likely for 
mounting through firewalls.

--------------020607070101060005060704
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


--------------020607070101060005060704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------020607070101060005060704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020607070101060005060704--
