From: Edward Hibbert <EH@dataconnection.com>
Subject: RE: [NFS] Disabling Symbolic Link Content Caching in NFS Client
Date: Tue, 3 Jun 2003 14:33:45 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <CFCD2C778CF1D611B5B400065B04D5C84A736F@KENTON>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: viro@math.psu.edu, davem@redhat.com, ezk@cs.sunysb.edu,
	indou.takao@jp.fujitsu.com, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: 'Vivek Goyal' <vivek.goyal@wipro.com>, trond.myklebust@fys.uio.no,
	Ion Badulescu <ionut@badula.org>
List-ID: <nfs.lists.sourceforge.net>



-----Original Message-----
From: Vivek Goyal [mailto:vivek.goyal@wipro.com]
Sent: Tuesday, June 03, 2003 2:21 PM
To: trond.myklebust@fys.uio.no; Ion Badulescu
Cc: viro@math.psu.edu; davem@redhat.com; ezk@cs.sunysb.edu;
indou.takao@jp.fujitsu.com; nfs@lists.sourceforge.net;
linux-kernel@vger.kernel.org; Vivek Goyal
Subject: RE: [NFS] Disabling Symbolic Link Content Caching in NFS Client

<snip>

You are right. But our idea is to provide an option to disable/enable
caching based on the nature of intended application.

[EH] Hear hear :-).  

Our application consists of a number of machines collaborating on a shared
database over NFS.  We therefore require the ability to force data to be
sync'd from the client to the backend - and at the moment we do this by
disabling caching completely, via the noac option and acquiring and
releasing non-exclusive locks round io calls.

Any improvements in the granularity of control over NFS client-side caching
would be very valuable to us.

Regards,

Edward Hibbert
Internet Applications Group
Data Connection Ltd
Tel:	+44 131 662 1212		Fax:	+44 131 662 1345
Email:	eh@dataconnection.com	Web:	http://www.dataconnection.com
