Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e37.co.us.ibm.com ([32.97.110.158]:54415 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934057Ab2DLOao (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Apr 2012 10:30:44 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 12 Apr 2012 08:30:43 -0600
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id B5905C90071
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 10:30:36 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3CEUa47255140
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 10:30:36 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3CETlrR028239
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 11:29:48 -0300
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q3CETkHu028164
	for <linux-nfs@vger.kernel.org>; Thu, 12 Apr 2012 11:29:46 -0300
Date: Thu, 12 Apr 2012 09:29:46 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: How to manage EDQUOT on the server side
Message-ID: <20120412142946.GB29891@us.ibm.com>
References: <4F86E4E0.8000703@cea.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F86E4E0.8000703@cea.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Are you using Linux client? I think there is a bug where the client
reports EIO rather than QUOTA/NOSPC errors under some circumstances.

I didn't know about client looping on the same WRITE call though!

Thanks, Malahal.

DENIEL Philippe [philippe.deniel@cea.fr] wrote:
> Hi,
> 
> I am currently busy with implementing quota management in my nfs
> server (nfs-ganesha).
> I have efficient way to make NFS3_WRITE detecting an IO that exceeds
> data quota, and use that to return NFS3ERR_DQUOT.
> Wireshark shows me that nfs reply contains NFS3ERR_DQUOT, but the
> client starts looping on the same WRITE call. By the end, by test
> application (a simple 'dd') end with "I/O Error".
> Did I miss something when implementing this ?
> I had no rquotad running for the share at the time the test was
> running, should I have a co-related rquotad running as well ?
> 
>    Regards
> 
>       Philippe
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

