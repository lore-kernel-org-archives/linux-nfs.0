From: "Venkatesh KS" <venkatesh.ks@gmail.com>
Subject: linux nfs client tcp timeout
Date: Fri, 6 Apr 2007 21:40:00 +0530
Message-ID: <4cf2912c0704060910n33a269f3xcce6967a3abafc92@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0414142185=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HZr0h-0006EC-SS
	for nfs@lists.sourceforge.net; Fri, 06 Apr 2007 09:10:00 -0700
Received: from ug-out-1314.google.com ([66.249.92.170])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HZr0j-0000iQ-PH
	for nfs@lists.sourceforge.net; Fri, 06 Apr 2007 09:10:02 -0700
Received: by ug-out-1314.google.com with SMTP id z38so1276073ugc
	for <nfs@lists.sourceforge.net>; Fri, 06 Apr 2007 09:10:00 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0414142185==
Content-Type: multipart/alternative;
	boundary="----=_Part_30671_10153919.1175875800668"

------=_Part_30671_10153919.1175875800668
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

I lost trace of a machine which was hung for 2 hours. The only culprits I
can see are nfs write requests.
The mount is for tcp, soft, retrans=4. Unfortunately I couldnt gather much
information.

The file is opened O_SYNC and write sizes are average 4k. There could not
have
been more than 40k worth writes against the server.

When I ran tests against a dead server, I saw timeouts of about 3 minutes
consistently.
Only the first request took about 18mins to timeout.

So what is the timeout characteristics for tcp in linux nfs client and what
parameters
can influence it?

regards,
-venkatesh

------=_Part_30671_10153919.1175875800668
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,<br><br>I lost trace of a machine which was hung for 2 hours. The only culprits I can see are nfs write requests.<br>The mount is for tcp, soft, retrans=4. Unfortunately I couldnt gather much information.<br><br>The file is opened O_SYNC and write sizes are average 4k. There could not have
<br>been more than 40k worth writes against the server.<br><br>When I ran tests against a dead server, I saw timeouts of about 3 minutes consistently.<br>Only the first request took about 18mins to timeout.<br><br>So what is the timeout characteristics for tcp in linux nfs client and what parameters
<br>can influence it?<br><br>regards,<br>-venkatesh<br>

------=_Part_30671_10153919.1175875800668--


--===============0414142185==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0414142185==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0414142185==--
