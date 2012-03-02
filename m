Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45972 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745Ab2CBU5L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Mar 2012 15:57:11 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q22KvAHH026437
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 15:57:11 -0500
Received: from badhat.bos.devel.redhat.com (vpn-11-150.rdu.redhat.com [10.11.11.150])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q22KvAO9029324
	for <linux-nfs@vger.kernel.org>; Fri, 2 Mar 2012 15:57:10 -0500
Message-ID: <4F513429.1050209@RedHat.com>
Date: Fri, 02 Mar 2012 15:57:13 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Get normalized paths for comparing NFS export paths
References: <1328233332-26020-1-git-send-email-malahal@us.ibm.com> <4F2BC1C0.8070900@panasas.com> <20120203231623.442fefde@notabene.brown> <20120203142945.GA31805@us.ibm.com> <4F2E620F.5090100@panasas.com> <20120207204401.GA31752@us.ibm.com> <4F511B21.1020907@RedHat.com> <20120302192758.GA28389@us.ibm.com>
In-Reply-To: <20120302192758.GA28389@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/02/2012 02:27 PM, Malahal Naineni wrote:
>> Question, How does this patch stop the mtab from getting polluted with
>> the device name with multiple "/"? 
> 
> It doesn't. Is that a problem? It only matches entries in /etc/mtab and
> /proc/mounts correctly for unmount to work.
> 
Well the problem I was working on was when a mount like
the following is done:
    mount server://export /mnt 

the umount /mnt will fail because the device name was written to 
/proc/mounts has the // stripped:

    server:/export /mnt nfs4 rw,relatime,vers=4...
 
but the device name in the mtab did not:

    rhelhat://home /mnt/home nfs rw,vers=4,... 

So what my patch does is "normalizes" the device name early
on in main, so the correct name used used through the mount
and when its written the mtab. Plus, for better or worses, 
since the new device name will always be shorter, I just 
reuse/rewrite the memory allocated for the argv vector.. 
Meaning there is no allocation... 

steved.
