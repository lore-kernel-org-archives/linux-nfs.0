From: "Guolin Cheng" <guolin@alexa.com>
Subject: NFS over TCP reports strange messags on Fedora FC1
Date: Tue, 30 Mar 2004 12:52:45 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41089CB27BD8D24E8385C8003EDAF7AB08483C@karl.alexa.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "ops" <ops@alexa.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8QE8-0002Vr-Kk
	for nfs@lists.sourceforge.net; Tue, 30 Mar 2004 12:52:52 -0800
Received: from birdwell-public.alexa.com ([67.107.182.10] helo=karl.presidio.alexa.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B8QE8-0006tu-8v
	for nfs@lists.sourceforge.net; Tue, 30 Mar 2004 12:52:52 -0800
To: "NFSUserList (E-mail)" <nfs@lists.sourceforge.net>
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

Hi,

  I got a strange problem on my newly installed Fedora FC1 box. On the =
FC1 box'es console I got the following error messages:

  RPC: bad TCP reclen 0x*********** (non-terminal)
  RPC: bad TCP reclen 0x*********** (large)
  ... (same, omitted) ....


  Any one know why? The nfs function seems working fine...

  The box is FC1, customized vanlina 2.4.25 kernel with libata patch,  =
"nfs server over tcp" is enabled.  The box works as a nfs server, while =
another redhat 8.0 box works as  a new client trying to mount FC1 by =
means of amd (similar to automount).

   Thanks.
   --Guolin Cheng



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
