From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: Re: An interesting performance thing ?
Date: Wed, 14 Dec 2005 16:59:42 -0800
Message-ID: <43A0BFFE.2050906@citi.umich.edu>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>	<17312.39940.985507.704832@cse.unsw.edu.au>	<43A0A0D5.4040804@citi.umich.edu>	<018401c60108$c9477f30$1500000a@americas.hpqcorp.net>	<17312.45710.867019.969182@cse.unsw.edu.au>	<43A0BC49.3070604@citi.umich.edu> <17312.49024.378295.414582@cse.unsw.edu.au>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080801060009050006060005"
Cc: Iozone <capps@iozone.org>, wli@holomorphy.com,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmhTJ-0000YE-PT
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 16:59:49 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EmhTI-00087r-JW
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 16:59:50 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17312.49024.378295.414582@cse.unsw.edu.au>
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
--------------080801060009050006060005
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> A good question is:  Do we ever need more than 4 bytes of hash
> value?
> We wouldn't for hash tables, but they may well be other uses of
> hashes.
> 
> If we don't then a function that maps and arbitrary mem buffer into
> a u32 would be suitable general for all uses or all architectures,
> though some special cases like 4byte and 8byte inputs could probably
> be optimised sensibly.
> 
>  I suspect the function given in
>    http://burtleburtle.net/bob/hash/evahash.html
> 
> my really be a good choice.  
> It does about 40 add/subtracts for each 4bytes, but seems to have good
> properties.
> (Hmm.. that is probably similar to a constant 32bit multiply, but
>  maybe the current code with a better non-sparse prime is just as
>  good).

i haven't looked at how the network layer handles this issue, but it 
might be a good start if there is something there to reuse.

--------------080801060009050006060005
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


--------------080801060009050006060005--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
