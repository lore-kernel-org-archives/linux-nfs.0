From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: wiki.linux-nfs.org
Date: Mon, 27 Feb 2006 07:56:23 -0800
Message-ID: <44032127.1070008@citi.umich.edu>
References: <200602251810.50744.bernd-schubert@gmx.de>
	<4400CC16.3040606@citi.umich.edu>
	<200602261454.51003.bernd-schubert@gmx.de>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030501080802090302090400"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Bernd Schubert <bernd-schubert@gmx.de>
In-Reply-To: <200602261454.51003.bernd-schubert@gmx.de>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

This is a multi-part message in MIME format.
--------------030501080802090302090400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Bernd Schubert wrote:
>>by adding the FAQ to the wiki, are you proposing that it should be
>>removed from sourceforge, and maintained by whomever wants to edit the
> 
> 
> That was the idea, but thatswhy I also asked for objections.

you posted your question at 9am (EST) on a non-workday, then you waited 
less than an hour before proceeding with the transfer.  that's hardly 
"asking for objections."

also, why didn't you contact me about this first?  i am the FAQ 
maintainer, after all.  is there a problem you are trying to address? 
is there something missing in the FAQ?  have i been slacking?

>>wiki pages?  i'm not really comfortable with that.  the FAQ is very very
>>carefully crafted and vetted so that it contains good information.
> 
> 
> Well, thats the general problem of a wiki. Usually it works, but sometimes 
> there is vandalism. On the other hand, most pages of the NFSv4 stuff also can 
> be edited by all. 
> Maybe we should add a page where people wanting to modify the wiki can enter 
> their username and email and Bryce can unlock them on request? (I hope this 
> is possible with mediawiki, we unlock per user with moinmoin).

i think wikis are a great tool, but here's the problem.

if anyone (in the NFS community) can edit the FAQ, what stops people 
from adding erroneous advice, or even advice that opens a security hole 
or that could cause silent data corruption?

for example, what happens if someone comes along and sees the "async" 
export option on the server and says "oh wow!  i can make my server 10x 
faster with this!  i'm going to add something to the FAQ that encourages 
everyone to use the 'async' export option!"

or even worse, someone adds advice to export shares without root 
squashing because it makes accessing the data "so much easier", or 
misconfigure Kerberos, and on and on.

sure, you can back it out easily, because it's a wiki.  but this all 
depends on us knowing the NFS implementation well enough, testing the 
advice, and being on top of the changes so we can quickly remove advice 
that is destructive.

basically, people trust that this information won't screw them.  if we 
let anyone edit this page, it will become worthless information.  you 
don't see the Linux kernel developed this way, and for exactly the same 
reasons.

i don't deny that the FAQ and How-To could use some help.  but please, 
let's reasonably discuss why we want to do this first, and see if we can 
address those issues with what we have.

--------------030501080802090302090400
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


--------------030501080802090302090400
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--------------030501080802090302090400--
