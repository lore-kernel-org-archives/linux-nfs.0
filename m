Return-Path: linux-nfs-owner@vger.kernel.org
Received: from earth.cora.nwra.com ([4.28.99.180]:45975 "EHLO
	earth.cora.nwra.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030654Ab2CGWM4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Mar 2012 17:12:56 -0500
Received: from orca.cora.nwra.com (orca.cora.nwra.com [10.10.20.2])
	(authenticated bits=0)
	by earth.cora.nwra.com (8.13.8/8.13.8) with ESMTP id q27MCrPq007453
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 7 Mar 2012 15:12:53 -0700
Message-ID: <4F57DD65.5090202@cora.nwra.com>
Date: Wed, 07 Mar 2012 15:12:53 -0700
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFS mount commands hanging
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm starting to see mount commands on my Fedora 15/16 clients hanging 
accessing CentOS 5.7 servers.  I've filed a fedora bug here:

https://bugzilla.redhat.com/show_bug.cgi?id=791311

that includes a packet capture.  Packets seem to be the following repeating 
very fast:

   1   0.000000   10.10.11.2 -> 10.10.10.1   NFS V4 COMP Call <EMPTY> PUTROOTFH
PUTROOTFH;GETFH GETFH;GETATTR GETATTR
   2   0.000029   10.10.41.5 -> 10.10.10.1   NFS V4 COMP Call <EMPTY> PUTROOTFH
PUTROOTFH;GETFH GETFH;GETATTR GETATTR
   3   0.000072   10.10.10.1 -> 10.10.11.2   NFS V4 COMP Reply (Call In 1)
<EMPTY> PUTROOTFH PUTROOTFH;GETFH GETFH;GETATTR GETATTR
   4   0.000087   10.10.10.1 -> 10.10.41.5   NFS V4 COMP Reply (Call In 2)
<EMPTY> PUTROOTFH PUTROOTFH;GETFH GETFH;GETATTR GETATTR


Any help tracking this down would be greatly appreciated.

-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder Office                  FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com
