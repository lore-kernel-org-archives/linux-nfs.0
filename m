From: "Bruce Allan" <bruce.allan@us.ibm.com>
Subject: Re: Re: 1279 mounts
Date: Mon, 29 Apr 2002 16:50:55 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF6661F22B.C4CE52F9-ON88256BAA.0081C65C@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 172KvL-0003oA-00
	for <nfs@lists.sourceforge.net>; Mon, 29 Apr 2002 16:51:15 -0700
To: Pete Zaitcev <zaitcev@redhat.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Well, count me as another who would like to see the unnamed major and NFS
parts make it into the 2.4 kernel.  I've had a number of conversations in
which there was an expressed interest in more than 246 or so mount points.
With what release/whatever do you ship the unnamed majors part?

Thanks,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



                                                                                                                                         
                      Pete Zaitcev                                                                                                       
                      <zaitcev@redhat.com>        To:       Panu Matilainen <pmatilai@welho.com>                                         
                      Sent by:                    cc:       Pete Zaitcev <zaitcev@redhat.com>, nfs@lists.sourceforge.net,                
                      nfs-admin@lists.sour         linux-kernel@vger.kernel.org                                                          
                      ceforge.net                 Subject:  [NFS] Re: 1279 mounts                                                        
                                                                                                                                         
                                                                                                                                         
                      04/27/2002 06:32 PM                                                                                                
                                                                                                                                         
                                                                                                                                         




> Date: Fri, 26 Apr 2002 11:25:33 +0300 (EEST)
> From: Panu Matilainen <pmatilai@welho.com>

> I've got quite a few users here who "need" this functionality and it's
> included in our RH-based custom kernels. Having it as a separate patch
> for 2.4 is no problem, for 2.5 I'm hoping we finally move to 32bit device
> numbers...

Mind, we only ship the unnamed majors part, but not the NFS part.
There is no word from util-linux maintainer about required
changes to mount(8), so I was cautious about doint that.

-- Pete

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
