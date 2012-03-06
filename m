Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14406 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758073Ab2CFA2L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 19:28:11 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q260SBOd010164
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 19:28:11 -0500
Received: from badhat.bos.devel.redhat.com (vpn-9-158.rdu.redhat.com [10.11.9.158])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q260SA73022873
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 19:28:11 -0500
Message-ID: <4F555A1F.5090102@RedHat.com>
Date: Mon, 05 Mar 2012 19:28:15 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] umount.nfs: normalize path names during umounts.
References: <1330976165-19849-1-git-send-email-steved@redhat.com> <1330976165-19849-2-git-send-email-steved@redhat.com> <20120305212015.GA21904@us.ibm.com> <20120305213005.GB21904@us.ibm.com>
In-Reply-To: <20120305213005.GB21904@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/05/2012 04:30 PM, Malahal Naineni wrote:
> Malahal Naineni [malahal@us.ibm.com] wrote:
>>>  		while (pmc->m.mnt_fsname[nlen - 1] == '/')
>>>  			nlen--;
>>> -		if (strncmp(pmc->m.mnt_fsname, mc->m.mnt_fsname, nlen) != 0)
>>> -			continue;
>>> +		/*
>>> +		 * When the mtab and /proc/mounts are not the same
>>> +		 * file, normalize the path in the mtab if needed.
>>> +		 */
>>> +		if (mtab_is_writable())
>>> +			normpath = normalize_path(mc->m.mnt_fsname);
>>> +
>>> +		if (strncmp(pmc->m.mnt_fsname, mc->m.mnt_fsname, nlen) != 0) {
>>> +			/* Is there a normalized path, if so compare that one too */
>>> +			if (normpath == NULL)
>>> +				continue;
>>> +			if (strncmp(pmc->m.mnt_fsname, normpath, nlen) != 0)
>>> +				continue;
>>
>> You need to free normpath here before the "continue".
> 
> Better yet, you don't need to normalize the path inside the loop. The
> path you normalize doesn't change, so keep it outside "do while" loop.
Your are right... thank you!

steved.
