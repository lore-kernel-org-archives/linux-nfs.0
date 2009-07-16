From: David Warren <warren-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org>
Subject: server locks up at boot
Date: Thu, 16 Jul 2009 13:44:00 -0700
Message-ID: <4A5F9110.4050208@atmos.washington.edu>
Reply-To: warren-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060202060407000307040603"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f197.google.com ([209.85.222.197]:62209 "EHLO
	mail-pz0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933322AbZGPUoD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jul 2009 16:44:03 -0400
Received: by pzk35 with SMTP id 35so247988pzk.33
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2009 13:44:02 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060202060407000307040603
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

We have been having a problem for a while now with kernels ranging from 
2.6.26 through 30. When a boots and starts the nfs server, it reads the 
/var/lib/nfs/v4recovery directory. If this directory is empty everything 
is fine. If it is not, all nfs related processes go into D wait and 
never return. Any other attempt to read the directory results in that 
process getting stuck in D wait as well. This happens on a variety of 
systems, all running Debian Lenny (happened with etch also) with kernels 
ranging from 2.6.26 - 2.6.31-rc2 serving disks via nfs4. if you boot 
single user and clear out the directory, everything is fine. Also, there 
is never any problem logged anywhere.

So, my questions are:

What is this directory really used for? It doesn't seem to need it to 
reestablish connections
Anyone have any idea what is going on or suggestions for finding out?


--------------060202060407000307040603
Content-Type: text/x-vcard; charset=utf-8;
 name="warren.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="warren.vcf"

begin:vcard
fn:David Warren
n:Warren;David
org:Atmospheric Sciences
adr:Dept of Atmospheric Sciences, Box 351640;;University of Washington;Seattle;WA;98195-1640;USA
email;internet:warren-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org
title:Software Engineer
tel;work:206 543-0945
url:http://www.atmos.washington.edu
version:2.1
end:vcard


--------------060202060407000307040603--
