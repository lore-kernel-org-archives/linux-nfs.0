From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: NFS performance tuning
Date: Sun, 08 Jan 2006 08:44:17 -0500
Message-ID: <43C11731.7030003@citi.umich.edu>
References: <43BE9EC3.3090108@totalflood.com> <32f0438a5087c2ea289922bbacb1897d@local> <Pine.LNX.4.64.0601081449320.19300@eagle.themaw.net> <06259ef940d5d01fc15319edce982acc@local>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000308030403060908040000"
Cc: Ian Kent <raven@themaw.net>,
	Stephen Carville <stephen@totalflood.com>,
	NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Evaqa-0001Ni-75
	for nfs@lists.sourceforge.net; Sun, 08 Jan 2006 05:44:36 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EvaqY-0003x7-NN
	for nfs@lists.sourceforge.net; Sun, 08 Jan 2006 05:44:36 -0800
To: Blake Golliher <golliher@yahoo-inc.com>
In-Reply-To: <06259ef940d5d01fc15319edce982acc@local>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------000308030403060908040000
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Blake Golliher wrote:
> 
> On Jan 7, 2006, at 10:51 PM, Ian Kent wrote:
> 
>> On Fri, 6 Jan 2006, Blake Golliher wrote:
>>
>>> Did you specify using a 32k read and write size, that I didn't see 
>>> somewhere?
>>> If you have a very clean network, you could get an advantage of using 
>>> UDP as
>>> well.  I'm not sure which transport you are using though.
>>>
>>> Oh I see a mention of nfs v2 tcp.  Well, I'd recommend moving to nfs 
>>> v3, using
>>> a 64k read/write size, and using UDP.  That might give you some 
>>> gains.  Of
>>> course, I'm usually a TCP bigot for nfs transport, but for a very clean,
>>> almost back to back, dedicated switch type of environment, I'll allow 
>>> it.
>>
>>
>> Mmm. I thought UDP was max. 8k read and write size and 32k was the max.
>> for TCP.
> 
> 
> The linux nfs client supports, at least, a 64k block transfer size.  I 
> don't believe it's constrained by transport protocol.

hi blake-

as of 2.6.15, the stock Linux NFS client supports up to 32KB read and 
write size for NFS versions 2, 3, and 4, and for UDP and TCP.

the recommended r/wsize for UDP is 8KB simply to avoid IP fragment 
storms.  on a clean network with few other clients, 32KB with UDP will 
probably work well.

soon, the Linux NFS client will support up to 1MB r/wsize, depending on 
the network transport and the server's capabilities.

--------------000308030403060908040000
Content-Type: text/x-vcard; charset=utf-8;
 name="cel.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="cel.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Charles
org:Network Appliance, Incorporated;Open Source NFS Client Development
adr:535 West William Street, Suite 3100;;Center for Information Technology Integration;Ann Arbor;MI;48103-4943;USA
email;internet:cel@citi.umich.edu
title:Member of Technical Staff
tel;work:+1 734 763-4415
tel;fax:+1 734 763 4434
tel;home:+1 734 668-1089
x-mozilla-html:FALSE
url:http://troy.citi.umich.edu/u/cel/
version:2.1
end:vcard


--------------000308030403060908040000--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
