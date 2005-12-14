From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: An interesting performance thing ?
Date: Wed, 14 Dec 2005 14:46:45 -0800
Message-ID: <43A0A0D5.4040804@citi.umich.edu>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net> <17312.39940.985507.704832@cse.unsw.edu.au>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020706070808030400090307"
Cc: Iozone <capps@iozone.org>, wli@holomorphy.com,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmfOk-0008RR-3a
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 14:46:58 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EmfOh-0008MP-Tb
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 14:46:58 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17312.39940.985507.704832@cse.unsw.edu.au>
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
--------------020706070808030400090307
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> William, Chunk:  Any suggestions on whether a straight multiply would
> be too expensive, or what else we could do to make hash_long both fast
> and effective?

my original proposal was a hash function which computed the index by a 
single multiplication with a large prime number.  i was told that 
multiplication was too expensive, especially on older platforms, so the 
existing computation took its place.  but i don't think anyone ever did 
any real studies.  i can't imagine that multiplication would be worse 
than extra elements in a hash chain, especially on modern CPU architectures.

--------------020706070808030400090307
Content-Type: text/x-vcard; charset=utf-8;
 name="cel.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="cel.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Network Appliance, Incorporated;Open Source NFS Client Engineering
email;internet:cel@citi.umich.edu
title:Member of Technical Staff
x-mozilla-html:FALSE
url:http://www.monkey.org/~cel
version:2.1
end:vcard


--------------020706070808030400090307--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
