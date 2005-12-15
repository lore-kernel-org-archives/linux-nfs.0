From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: Re: An interesting performance thing ?
Date: Wed, 14 Dec 2005 16:43:53 -0800
Message-ID: <43A0BC49.3070604@citi.umich.edu>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>	<17312.39940.985507.704832@cse.unsw.edu.au>	<43A0A0D5.4040804@citi.umich.edu>	<018401c60108$c9477f30$1500000a@americas.hpqcorp.net> <17312.45710.867019.969182@cse.unsw.edu.au>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010205000407050608070004"
Cc: Iozone <capps@iozone.org>, wli@holomorphy.com,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmhE0-0007om-Aq
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 16:44:00 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EmhDz-0002BG-1H
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 16:44:00 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17312.45710.867019.969182@cse.unsw.edu.au>
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
--------------010205000407050608070004
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> The trouble is that just because inet_lnaof makes the final hash
> better for your mix of clients, that doesn't mean it won't make it
> worse for someone else.  I admit that I cannot provide a like sample
> mix of clients what would be worse with inet_lnaof, but that doesn't
> mean they don't exist.
> 
> If the only symptom that has been identified is that it makes a
> locking race easier to hit, then the obvious first solution is to fix
> that locking race, and I believe such a fix is available.
> 
> If anyone were experiencing a measurable slowness due to the bad hash,
> then I would have not problem suggesting they try the inet_lnaof
> solution.
> 
> But I don't propose submitting it to Linus because - useful as it is -
> it is simply wrong.
> We need to fix that hash function, and this clear problem is a good
> motivation to do that.
> 
> Or to put it another way, I don't think it is clear that we *need* a
> solution for the immediate future.

we might also think a little bit of the future (IPv6).

IPv6 addresses are larger than IPv4 addresses, so they will need their 
own hash function, *or* we will have to design a reasonable hash 
function for variably-sized addresses now, which seems like a harder 
problem.

--------------010205000407050608070004
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


--------------010205000407050608070004--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
