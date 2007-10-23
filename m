From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: about /proc/net/rpc/nfsd
Date: Tue, 23 Oct 2007 11:07:13 -0400
Message-ID: <471E0E21.5050606@oracle.com>
References: <471D17F8.5060709@cesca.es> <471D1DF2.4070201@oxeva.fr>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020004070800080201040405"
Cc: nfs@lists.sourceforge.net
To: Gabriel Barazer <gabriel@oxeva.fr>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IkLNT-0001Q5-2k
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 08:09:07 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IkLNW-0001Ci-7H
	for nfs@lists.sourceforge.net; Tue, 23 Oct 2007 08:09:12 -0700
In-Reply-To: <471D1DF2.4070201@oxeva.fr>
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
--------------020004070800080201040405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Gabriel Barazer wrote:
> On 10/22/2007 11:36:56 PM +0200, Jordi Prats <jprats@cesca.es> wrote:
>> Hi all,
>> I've been researching the meaning of the contents of the 
>> /proc/net/rpc/nfsd file using the 2.6.23 kernel sources.
>>
>>
>> Sorry for this so long mail... That's all what I've got reading the 
>> source files. There's anything incorrect? There's some "educated guests" 
>>   So, could anyone please confirm or refute them?
>>
>> If you what me to do something with this I'd be glad of it!
> 
> Wow this is an awesome job you've done here to document precisely this 
> proc file. I've tagged your mail and copied it in a safe place.  I'm 
> sure this would be very useful to keep a place where all these proc 
> files are explained like this, maybe on the linux-nfs wiki ?

This belongs in the NFS server performance chapter of the NFS How-To. 
The How-To's maintainer is csmithere@gmail.com.

--------------020004070800080201040405
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
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------020004070800080201040405
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------020004070800080201040405
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020004070800080201040405--
