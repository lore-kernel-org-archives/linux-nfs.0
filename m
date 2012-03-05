Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20829 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932150Ab2CEPDh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 10:03:37 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q25F3bhZ018313
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 10:03:37 -0500
Received: from badhat.bos.devel.redhat.com (vpn-9-158.rdu.redhat.com [10.11.9.158])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q25F3amD014728
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 10:03:37 -0500
Message-ID: <4F54D5CC.5050402@RedHat.com>
Date: Mon, 05 Mar 2012 10:03:40 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Get normalized paths for comparing NFS export paths
References: <4F513429.1050209@RedHat.com> <20120302220108.GA17119@us.ibm.com> <4F525741.2060404@RedHat.com> <1330801976.2781.19.camel@lade.trondhjem.org> <4F53ED3C.2020209@RedHat.com> <4F53F39E.9050802@RedHat.com> <1330903600.14357.10.camel@lade.trondhjem.org> <4F5402E4.4030506@RedHat.com> <1330913047.14357.19.camel@lade.trondhjem.org> <4F54A9BD.4020702@RedHat.com> <20120305144743.GA31639@us.ibm.com>
In-Reply-To: <20120305144743.GA31639@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/05/2012 09:47 AM, Malahal Naineni wrote:
> Steve Dickson [SteveD@redhat.com] wrote:
>>
>>> Which is why I'm asking you if you can't copy from /proc/mounts. Distros
>>> which already have a symlink betweek /etc/mtab and /proc/mounts don't
>>> have any of these problems...
>>>
>> Personally I think it simpler to just normalize the paths before 
>> writing it to the mtab verses open up and searching /proc/mounts
>> esp on client where there is large amount of mounts...  
> 
> We always open up and search /proc/mounts today for the matching
> mountpoint to know the exact version of nfs, right? 
Yes, we open up /proc/mount to get the authoritative version.

> The umount time normalization is going to cost us? 
Nothing... but I thought it might be easier to do the 
normalization after a successful v4 iff the the mtab
is writable.
 
> Or you proposing a patch that is going to avoid opening up /proc/mounts altogether?
No... umount has to open /proc/mounts...

steved.

