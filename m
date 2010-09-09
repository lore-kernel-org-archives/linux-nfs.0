From: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
Subject: How to get the file path from file handle - NFS.
Date: Thu, 9 Sep 2010 08:24:40 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90D1991A4@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod6og114.obsmtp.com ([64.18.1.33]:37558 "HELO
	exprod6og114.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753055Ab0IIMYw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Sep 2010 08:24:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I seek some pointers on how to obtain the file path from the file
handle. The NFS protocol exchange the file handle between the Server and
Client. 
I want to extract the file path at client side from the available file
handle. 

I went through some of the reference documents. It say- 
The mapping exists in /var/nfs/fhpath or /etc/default/nfslogd files. And
can be configured through /etc/nfs/nfslog.conf.
http://docstore.mik.ua/orelly/networking_2ndEd/nfs/ch14_06.htm

But essentially I am looking forward extracting it through application C
code (may be getting the pointer to the hash table etc.)- the reason
being I want to avoid file open, read operations (on the nfslogd file)
due to performance issue. 

Could someone please advice if it is possible to extract it through some
structure? Can we directly try to read the mapping hash table at client
side?


--
Thanks,
Nilesh
x46222
Yahoo IM: nilesh_tayade85
