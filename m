From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: df inconsistent from one OS to another
Date: Fri, 22 Oct 2004 18:05:46 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098493546.3601.720.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CLALu-0003IK-3g
	for nfs@lists.sourceforge.net; Fri, 22 Oct 2004 18:05:50 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CLALt-00025H-D3
	for nfs@lists.sourceforge.net; Fri, 22 Oct 2004 18:05:50 -0700
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
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


We have an RHEL 3 system, which is NFS exporting a Lustre filesystem, to
an AIX 5.1 system.

But I'm getting the following inconsistent results:

AIX 5.1:
esmf04m-root> df -k /mnt/lustre
Filesystem    1024-blocks      Free %Used    Iused %Iused Mounted on
esmft2:/mnt/lustre 125082071680 123453448000    2%    24757     1%
/mnt/lustre

RHEL 3:
[root@esmft2 lustre]# df /mnt/lustre
Filesystem           1K-blocks      Used Available Use% Mounted on
config               22002856592 508400840 20376770744   3% /mnt/lustre
[root@esmft2 lustre]# 

Based on the number of disks aggregated into the underlying lustre
filesystem, we believe that the df on the RHEL 3 system is correct.

I prowled around in the python os and vfstat modules, and determined
that the AIX system believes that the filesystem's fundamental block
size is 32768, while the RHEL 3 system believes the filesystem's
fundamental block size is 8192.  While these numbers differ by a factor
of 4, dividing the AIX number by 4 does not give the hoped-for result.

Does anyone have any guesses (or better :) as to what might be causing
this inconsistency?

Thanks!

-- 
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
