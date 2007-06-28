From: "Matthew Boeckman" <matthew.boeckman@gmail.com>
Subject: rsize/wsize large blocks cause server crash?
Date: Thu, 28 Jun 2007 07:25:12 -0500
Message-ID: <79b746130706280525k51dd7f6y354ba632c5b9e37e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0733325873=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3t3d-0001aB-TF
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 05:25:12 -0700
Received: from an-out-0708.google.com ([209.85.132.248])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3t3g-00074g-V0
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 05:25:13 -0700
Received: by an-out-0708.google.com with SMTP id b38so114642ana
	for <nfs@lists.sourceforge.net>; Thu, 28 Jun 2007 05:25:12 -0700 (PDT)
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

--===============0733325873==
Content-Type: multipart/alternative;
	boundary="----=_Part_59601_20032599.1183033512208"

------=_Part_59601_20032599.1183033512208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello list!

I'm seeing some odd behavior on my nfs server, and wanted to bounce an idea
off the list. We have approximately 6 web/application servers that have
mounted from an NFS head. All systems involved are RHEL5 2.6.8-18-8, IBM
Blades (dual opteron, 4 gb ram, gigE). The share is an iscsi RAID5 LUN from
an EMC device. I am essentially using the stock nfs server config (8 start
servers, no changes to rmem/wmem, etc). I had been mounting with:

soft,intr,rsize=32768,wsize=32768

What I saw was the NFS server crash with a kernel panic, about 8 times in
the last few days. Each time the server crashed it was under a bit of load,
all NFS related (+5.5 load average). I should mention that the blade serving
NFS is not running any other applications. I have also isolated this from
being related to a single blade/hardware problem by moving the NFS services
from one blade to another: same behavior on both.

Tuesday, after another system crash, I bumped down the rsize/wsize to 8192
on all clients, and have not experienced a crash since then- now 40 hours
and counting. Under the higher block sizes the most I had seen was about 4
hours of uptime.

I'll mention that our application is a java based image program - we write a
pretty hefty amount of large postscript out to the NFS mount, and do
frequent permission/timestamp lookups.

My question to the list: is my current uptime just lucky, or is it possible
that the larger block sizes may have been causing the server to crash? Are
there any known conditions where under load the nfs server is unable to keep
up with larger block sizes, where smaller block sizes and the same load it
handles better? I am aware that older kernels/cards don't play well with the
larger block size, but I did not think this is an issue with my shiny new
ibm boxes.

Any thoughts or advice is much appreciated!

Thanks,

Matthew

------=_Part_59601_20032599.1183033512208
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello list!<br><br>I&#39;m seeing some odd behavior on my nfs server, and wanted to bounce an idea off the list. We have approximately 6 web/application servers that have mounted from an NFS head. All systems involved are RHEL5 
2.6.8-18-8, IBM Blades (dual opteron, 4 gb ram, gigE). The share is an iscsi RAID5 LUN from an EMC device. I am essentially using the stock nfs server config (8 start servers, no changes to rmem/wmem, etc). I had been mounting with:
<br><br>soft,intr,rsize=32768,wsize=32768<br><br>What I saw was the NFS server crash with a kernel panic, about 8 times in the last few days. Each time the server crashed it was under a bit of load, all NFS related (+5.5 load average). I should mention that the blade serving NFS is not running any other applications. I have also isolated this from being related to a single blade/hardware problem by moving the NFS services from one blade to another: same behavior on both.
<br><br>Tuesday, after another system crash, I bumped down the rsize/wsize to 8192 on all clients, and have not experienced a crash since then- now 40 hours and counting. Under the higher block sizes the most I had seen was about 4 hours of uptime.
<br><br>I&#39;ll mention that our application is a java based image program - we write a pretty hefty amount of large postscript out to the NFS mount, and do frequent permission/timestamp lookups.<br><br>My question to the list: is my current uptime just lucky, or is it possible that the larger block sizes may have been causing the server to crash? Are there any known conditions where under load the nfs server is unable to keep up with larger block sizes, where smaller block sizes and the same load it handles better? I am aware that older kernels/cards don&#39;t play well with the larger block size, but I did not think this is an issue with my shiny new ibm boxes.
<br><br>Any thoughts or advice is much appreciated!<br><br>Thanks,<br><br>Matthew<br><br>

------=_Part_59601_20032599.1183033512208--


--===============0733325873==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0733325873==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0733325873==--
