From: vishal <vishal@endace.com>
Subject: NFS - RDMA over Infiniband - performance issue
Date: Tue, 09 Jan 2007 14:03:08 +1300
Message-ID: <1168304588.5086.42.camel@julia.et.endace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H45O9-0006mx-Fh
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 17:02:53 -0800
Received: from endace.smrn.com ([209.234.97.14] helo=www.endace.com)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H45OB-0008Bz-1c
	for nfs@lists.sourceforge.net; Mon, 08 Jan 2007 17:02:55 -0800
Received: from et.endace.com (203-97-51-114.dsl.clear.net.nz [203.97.51.114])
	by www.endace.com (8.13.4/8.12.10) with ESMTP id l0912dFx011316
	for <nfs@lists.sourceforge.net>; Mon, 8 Jan 2007 17:02:40 -0800 (PST)
Received: from julia.et.endace.com (julia.et.endace.com [192.168.64.33])
	(authenticated bits=0)
	by et.endace.com (8.13.5/8.12.11) with ESMTP id l0912WhW027032
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <nfs@lists.sourceforge.net>; Tue, 9 Jan 2007 14:02:37 +1300 (NZDT)
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

Hi,

    I am getting an average speed of ~100 MiB/s using NFS-RDMA over
Infiniband, writing to an md device. The local write speed was ~800
MiB/s. The kernel being used is 2.6.18.3. The tests were performed using
dd (various block sizes have been tried). I have fiddled with the rsize
and wsize as well, but that didn't make any difference. Can anyone
please help me out!

Thanks!

Vishal


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
