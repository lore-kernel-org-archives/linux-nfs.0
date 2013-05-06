Return-Path: linux-nfs-owner@vger.kernel.org
Received: from papaya.imsweb.com ([204.132.58.134]:58192 "EHLO
	papaya.imsweb.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755573Ab3EFTHM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 15:07:12 -0400
Received: from VARUNA.omni.imsweb.com (varuna.omni.imsweb.com [172.22.64.28])
	by papaya.imsweb.com (Postfix) with ESMTP id 12B255FF16
	for <linux-nfs@vger.kernel.org>; Mon,  6 May 2013 15:07:02 -0400 (EDT)
From: "Ashby, Jason (IMS)" <AshbyJ@imsweb.com>
To: "'linux-nfs@vger.kernel.org'" <linux-nfs@vger.kernel.org>
Subject: authrefrsh
Date: Mon, 6 May 2013 19:06:59 +0000
Message-ID: <B10E49DFB64A0A4D89A00D7C82B026D811EC51CD@VARUNA.omni.imsweb.com>
References: <B10E49DFB64A0A4D89A00D7C82B026D811EC5001@VARUNA.omni.imsweb.com>
 <B10E49DFB64A0A4D89A00D7C82B026D811EC51A6@VARUNA.omni.imsweb.com>
In-Reply-To: <B10E49DFB64A0A4D89A00D7C82B026D811EC51A6@VARUNA.omni.imsweb.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, I'm having a difficult time finding any info on the net about the "authrefrsh" value shown in the output of nfsstat -rc.  I understand it to mean "number of times authentication information had to be refreshed", but does it add to the overhead of nfs requests?  Does an authrefresh mean my nfs client is sending an authentication request to the nfs server?  I'm wondering if there is a correlation between degraded nfs performance and the number of authrefrsh?  I thought an authentication request with NFSv3 was only made when the client first mounts something.

Our Linux clients mount from a NetApp NFS server using NFSv3.  Our older Linux clients (SLES 9 SP4) have show better NFS performance than newer clients (SLES 11 SP2 and CentOS 6.4).  The only difference I see is that the old clients have authrefrsh=0 and the new clients have a very high number of authrefrsh.

Mount options used by all clients:  rsize=32768,wsize=32768,hard,nointr,rw,bg,vers=3,tcp,actimeo=0 0 0

Old clients...SLES 9 SP4 client (nfs-utils-1.0.6-103.28)
foo:~ # uname -a
Linux foo 2.6.5-7.308-smp #1 SMP Mon Dec 10 11:36:40 UTC 2007 x86_64 x86_64 x86_64 GNU/Linux

$ nfsstat -rc
Client rpc stats:
calls      retrans    authrefrsh
815256992   196        0

I have 10-15 sles 9 sp4 clients whose stats look like this, i.e. authrefrsh=0.

Newer clients...SLES 11 and CentOS 6 (nfs-utils-1.2.3-36.el6.x86_64)
$ nfsstat -rc
Client rpc stats:
calls      retrans    authrefrsh
152946408   0          152968735


These questions are about all I could find on the matter:
http://unix.stackexchange.com/questions/13557/slow-nfs-nfsstat-c-what-is-authrefrsh-aka-newcreds-field-about-in-detail
http://serverfault.com/questions/362442/what-causes-repeated-linux-nfs-client-side-rpc-credential-refreshing

Sorry if this is not the correct mailing list for this type of question, so please point me in the right direction if not.  Thanks for any info.

________________________________

Information in this e-mail may be confidential. It is intended only for the addressee(s) identified above. If you are not the addressee(s), or an employee or agent of the addressee(s), please note that any dissemination, distribution, or copying of this communication is strictly prohibited. If you have received this e-mail in error, please notify the sender of the error.
