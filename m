From: Tom Georgoulias <tom.georgoulias@motorola.com>
Subject: max memory size on input queue?
Date: Wed, 04 Jun 2003 11:07:09 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EDE192D.4000602@motorola.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from motgate2.mot.com ([136.182.1.10])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19NanN-0003eJ-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Jun 2003 09:07:25 -0700
Received: from az33exr03.mot.com (pobox3.mot.com [10.64.251.242])
	by motgate2.mot.com (Motorola/Motgate2) with ESMTP id h54G7NdS001173
	for <nfs@lists.sourceforge.net>; Wed, 4 Jun 2003 09:07:24 -0700 (MST)
Received: from az33exm31.corp.mot.com (az33exm31.corp.mot.com [10.64.65.145])
	by az33exr03.mot.com (Motorola/az33exr03) with ESMTP id h54G7AsZ019432
	for <nfs@lists.sourceforge.net>; Wed, 4 Jun 2003 11:07:16 -0500
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Is there any agreement on what is the safest, largest input queue memory 
size?  /etc/syconfig/nfs has an option to turn this value to 256k, so it 
that generally the best setting to use?  What about 512k?

Tom



-------------------------------------------------------
This SF.net email is sponsored by:  Etnus, makers of TotalView, The best
thread debugger on the planet. Designed with thread debugging features
you've never dreamed of, try TotalView 6 free at www.etnus.com.
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
