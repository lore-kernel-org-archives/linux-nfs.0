Return-Path: linux-nfs-owner@vger.kernel.org
Received: from engine03-30064-2.icritical.com ([93.159.202.47]:40365 "HELO
	engine03-30064-2.icritical.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752487AbaCGJsK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Mar 2014 04:48:10 -0500
Received: from engine03-30064-2.icritical.com ([127.0.0.1])
 by localhost (engine03-30064-2.icritical.com [127.0.0.1]) (amavisd-new, port 10024)
 with SMTP id 21677-06 for <linux-nfs@vger.kernel.org>;
 Fri,  7 Mar 2014 09:41:35 +0000 (GMT)
Received: from lismore.npm.ac.uk (localhost.localdomain [127.0.0.1])
	by localhost (Email Security Appliance) with SMTP id 80B878D6AE1_3199446B
	for <linux-nfs@vger.kernel.org>; Fri,  7 Mar 2014 09:41:26 +0000 (GMT)
Received: from Harris.npm.ac.uk (harris.npm.ac.uk [192.171.162.107])
	by lismore.npm.ac.uk (Sophos Email Appliance) with ESMTP id EA28C8D6895_3199445F
	for <linux-nfs@vger.kernel.org>; Fri,  7 Mar 2014 09:41:25 +0000 (GMT)
Message-ID: <53199445.3010808@pml.ac.uk>
Date: Fri, 7 Mar 2014 09:41:25 +0000
From: Ben Taylor <benj@pml.ac.uk>
MIME-Version: 1.0
To: <linux-nfs@vger.kernel.org>
Subject: NFS4 patch 08/20 (BAD_SEQID recovery)
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

We've been getting weird occasional failures on our NFS systems where
our processing gridnodes will gradually grind to a halt (we lose a
couple of machines a day requiring a reboot - hard reboot if left long
enough). Hunting through Wireshark dumps, the problem is that the NFS
client is making repeated requests to open the same file on our
fileserver and every one has the same owner ID and a sequence ID of 0
(which the server throws out again as a bad sequence ID). I've got a
dump I can give you if you want it.

I am convinced that the problem is that described in patch 08/20 from
Chuck Lever (see http://www.spinics.net/lists/linux-nfs/msg29413.html),
where in this case the client gets the same open owner ID from the
server and retries with that, which makes the server think it's the same
request and throw it out again. In that patch Chuck added a uniqifier to
the owner ID to avoid this problem.

The problem is that we can't find any kernel versions that include that
patch - easy way to
check is look for the " therefore safely retry using a new one. We
should still warn the user though..." part - if the "warn the user" part
is there, it's not been patched (we did check other bits of the patch
too). We're running both Fedora 17 and Fedora 19 at the moment (yes, I
know 17 is EOL), neither of which includes the patch. We also can't see
it in the NFS client or server trees at

http://git.linux-nfs.org/?p=trondmy/nfs-2.6.git;a=blob;f=fs/nfs/nfs4proc.c;h=2da6a698b8f7719c14eefec65e6148a48d030bb3;hb=HEAD#l2327

http://git.linux-nfs.org/?p=trondmy/nfs-2.6.git;a=blob;f=fs/nfs/nfs4proc.c;h=2da6a698b8f7719c14eefec65e6148a48d030bb3;hb=HEAD#l2327

...and nor does Chuck appear to have it in his merging tree:
http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=blob;f=fs/nfs/nfs4proc.c;h=15052b81df4245e4f797adb0d0b2e523338b23cc;hb=HEAD#l2327

Can anyone tell me what happened to this patch please? Was it lost or
superseded?

TIA
Ben

-- 
Ben Taylor <benj@pml.ac.uk>, http://rsg.pml.ac.uk/
Remote Sensing Group, Plymouth Marine Laboratory
Tel: +44 (0)1752 633432, Fax: +44 (0)1752 633101


Please visit our new website at www.pml.ac.uk and follow us on Twitter  @PlymouthMarine

Plymouth Marine Laboratory (PML) is a company limited by guarantee registered in England & Wales, company number 4178503. Registered Charity No. 1091222. Registered Office: Prospect Place, The Hoe, Plymouth  PL1 3DH, UK. 

This message is private and confidential. If you have received this message in error, please notify the sender and remove it from your system. You are reminded that e-mail communications are not secure and may contain viruses; PML accepts no liability for any loss or damage which may be caused by viruses.

