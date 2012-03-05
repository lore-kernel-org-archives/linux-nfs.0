Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47199 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756785Ab2CEMDT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 07:03:19 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q25C3I6b027242
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 07:03:19 -0500
Received: from badhat.bos.devel.redhat.com (vpn-9-158.rdu.redhat.com [10.11.9.158])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q25C3IcD009223
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 07:03:18 -0500
Message-ID: <4F54AB8A.40806@RedHat.com>
Date: Mon, 05 Mar 2012 07:03:22 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Get normalized paths for comparing NFS export paths
References: <4F2E620F.5090100@panasas.com> <20120207204401.GA31752@us.ibm.com> <4F511B21.1020907@RedHat.com> <20120302192758.GA28389@us.ibm.com> <4F513429.1050209@RedHat.com> <20120302220108.GA17119@us.ibm.com> <4F525741.2060404@RedHat.com> <1330801976.2781.19.camel@lade.trondhjem.org> <4F53ED3C.2020209@RedHat.com> <1330901196.14357.7.camel@lade.trondhjem.org> <20120305044638.GA12833@us.ibm.com>
In-Reply-To: <20120305044638.GA12833@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/04/2012 11:46 PM, Malahal Naineni wrote:
> Myklebust, Trond [Trond.Myklebust@netapp.com] wrote:
>> No. Please don't strip the multiple slashes either. Just leave the path
>> alone after you've separated it from the devicename.
>>
>> It is quite OK to normalize the path on the _client_ side (i.e.
>> change //mnt to /mnt or whatever) but don't touch the server side.
> 
> As I understand, we can normalize and store it in /etc/mtab and
> normalization is done by the kernel for /proc/mounts. In other words,
> follow the kernel and make the /etc/mtab entries consistent with the
> kernel.
> 
> In my patch, I decided to normalize at umount time when we compare the
> mtab and proc file entries.
> 
> Any opinion on which one is better?
I'm thinking either before the unmount or after a successful 
v4 mount...

steved.

