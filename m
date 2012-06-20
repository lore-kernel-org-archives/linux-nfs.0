Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ixe-mta-29-tx.emailfiltering.com ([194.116.199.160]:47897 "EHLO
	ixe-mta-29.emailfiltering.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753453Ab2FTCVm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jun 2012 22:21:42 -0400
Message-ID: <4FE13260.1050002@pml.ac.uk>
Date: Wed, 20 Jun 2012 03:16:00 +0100
From: Mike Grant <mggr@pml.ac.uk>
MIME-Version: 1.0
To: Christoph Bartoschek <bartoschek@gmx.de>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: Spurious permission denied
References: <43v5b9-ifa.ln1@barney.bruehl.pontohonk.de>
In-Reply-To: <43v5b9-ifa.ln1@barney.bruehl.pontohonk.de>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/19/2012 10:58 AM, Christoph Bartoschek wrote:
> we still have the problem that some users get permission denied for
> directories they normally can access. The problem only affects a single user
> at a time and automatically goes away after about 30 minutes.

We've seen this error quite a bit too, though never managed to pin it 
down well enough to report it as it's intermittent and unpredictable.  I 
agree that it seems to be server side and we tried a few things to get 
rid of it.  I'm not sure if they worked or if it's just in remission, 
but the two things that seemed to help most were:
  a) increase the amount of memory in the server (we went from 6 to 24GB)
  b) reduce dependence on NIS by (ick) hard coding key users into the 
server's /etc/passwd file.

We tried the latter because our NIS server was struggling a lot at the 
time and I'm not sure what happens if the NFS server fails to get a NIS 
response in a timely manner or gets a failed response (i,e. it can't 
identify the user).

It may be worth you seeing if the user id resolves correctly on the 
server at the time of the failure.  It might also be interesting to know 
what happens if you restart the NFS server when you have this problem. 
I'm wondering if the 30min thing indicates a cached bad credential or 
something that expires after a bit or perhaps the NFS server thread just 
gets recycled..

It may also be worth doing a capture on the server side at the same 
time, as that might show issues with NIS or whatever you use.  There's a 
good chance it may not be visible after the problem has occurred though, 
if it's cached somewhere.

Anyway, sorry that's not directly helpful, but maybe a few things to try!

Cheers,

Mike.

<br />
<hr />
<p><font face="Arial" size="1">
Plymouth Marine Laboratory<br />
Registered Office: <br />
Prospect Place<br />
The Hoe<br />
Plymouth  PL1 3DH
</font></p>

<p><font face="Arial" size="1">Website: <a href="http://www.pml.ac.uk">www.pml.ac.uk</a>
<br />
<a href="http://www.pml.ac.uk/pdf/PML%20Annual%20Review%202011_2.pdf">Click here for the latest PML Annual Review</a>
<br />
Registered Charity No. 1091222<br />
PML is a company limited by guarantee<br />
registered in England & Wales<br />
company number 4178503</font></p>

<p><font face="Arial" size="1" color="green">Please think before you print.</font></p>

<hr />

<p><font face="Arial" size="1">This e-mail, its content and any file attachments are confidential.</font></p>

<p><font face="Arial" size="1">If you have received this e-mail in error please do not copy, disclose it to any third party or use the contents or attachments in any way. Please notify the sender by replying to this e-mail or e-mail forinfo@pml.ac.uk and then delete the email without making any copies or using it in any other way.</font></p>

<p><font face="Arial" size="1">The content of this message may contain personal views which are not the views of Plymouth Marine Laboratory unless specifically stated.</font></p>

<p><font face="Arial" size="1">You are reminded that e-mail communications are not secure and may contain viruses. Plymouth Marine Laboratory accepts no liability for any loss or damage which may be caused by viruses.</font></p>

<hr />
<br />
<br />

