Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e35.co.us.ibm.com ([32.97.110.153]:51648 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693Ab2CEVaT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 16:30:19 -0500
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 5 Mar 2012 14:30:18 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 90C1B19D804A
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 14:30:09 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25LUEqW055502
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 14:30:14 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25LUBlr022501
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 14:30:11 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q25LUBcS022428
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 14:30:11 -0700
Date: Mon, 5 Mar 2012 15:30:05 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] umount.nfs: normalize path names during umounts.
Message-ID: <20120305213005.GB21904@us.ibm.com>
References: <1330976165-19849-1-git-send-email-steved@redhat.com>
 <1330976165-19849-2-git-send-email-steved@redhat.com>
 <20120305212015.GA21904@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120305212015.GA21904@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Malahal Naineni [malahal@us.ibm.com] wrote:
> >  		while (pmc->m.mnt_fsname[nlen - 1] == '/')
> >  			nlen--;
> > -		if (strncmp(pmc->m.mnt_fsname, mc->m.mnt_fsname, nlen) != 0)
> > -			continue;
> > +		/*
> > +		 * When the mtab and /proc/mounts are not the same
> > +		 * file, normalize the path in the mtab if needed.
> > +		 */
> > +		if (mtab_is_writable())
> > +			normpath = normalize_path(mc->m.mnt_fsname);
> > +
> > +		if (strncmp(pmc->m.mnt_fsname, mc->m.mnt_fsname, nlen) != 0) {
> > +			/* Is there a normalized path, if so compare that one too */
> > +			if (normpath == NULL)
> > +				continue;
> > +			if (strncmp(pmc->m.mnt_fsname, normpath, nlen) != 0)
> > +				continue;
> 
> You need to free normpath here before the "continue".

Better yet, you don't need to normalize the path inside the loop. The
path you normalize doesn't change, so keep it outside "do while" loop.

Regards, Malahal.

