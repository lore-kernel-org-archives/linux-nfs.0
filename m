From: "Murali Bashyam" <mbcoder@gmail.com>
Subject: unfsd strange behaviour ?
Date: Tue, 21 Nov 2006 23:58:20 -0800
Message-ID: <9c8209a10611212358o75127f4qd433e37c32fefc29@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1168520925=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gmmzs-0003aF-Ly
	for nfs@lists.sourceforge.net; Tue, 21 Nov 2006 23:58:20 -0800
Received: from nf-out-0910.google.com ([64.233.182.191])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gmmzt-00083v-PQ
	for nfs@lists.sourceforge.net; Tue, 21 Nov 2006 23:58:22 -0800
Received: by nf-out-0910.google.com with SMTP id c31so730281nfb
	for <nfs@lists.sourceforge.net>; Tue, 21 Nov 2006 23:58:20 -0800 (PST)
To: nfs@lists.sourceforge.net
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

--===============1168520925==
Content-Type: multipart/alternative;
	boundary="----=_Part_3794_26350437.1164182300122"

------=_Part_3794_26350437.1164182300122
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi

I am running unfsd 0.9.16 on a linux 2.6 machine. I notice that from a
client machine while reading a file (say  XYZ)  the NFS client does GETATTR
using a file handle corresponding to that file, and unfsd after processing
that request initiates a LOOKUP operation for another file in the same
directory. ? I would have expected the unfsd to do a LOOKUP for XYZ, but
instead it does LOOKUP for another file in the same directory. Perhaps the
unfsd is mapping that file handle to a different file name from what the
client thinks is the file name?

Murali

------=_Part_3794_26350437.1164182300122
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi<br><br>I am running unfsd 0.9.16 on a linux 2.6 machine. I notice that from a client machine while reading a file (say&nbsp; XYZ)&nbsp; the NFS client does GETATTR using a file handle corresponding to that file, and unfsd after processing that request initiates a LOOKUP operation for another file in the same directory. ? I would have expected the unfsd to do a LOOKUP for XYZ, but instead it does LOOKUP for another file in the same directory. Perhaps the unfsd is mapping that file handle to a different file name from what the client thinks is the file name?
<br><br>Murali<br>

------=_Part_3794_26350437.1164182300122--


--===============1168520925==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1168520925==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1168520925==--
