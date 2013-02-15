Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ax13.adsl.tnnet.fi ([217.112.254.13]:36971 "EHLO
	mail.opinsys.fi" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932773Ab3BOMNw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2013 07:13:52 -0500
Date: Fri, 15 Feb 2013 12:00:31 +0000 (UTC)
From: Tuomas =?utf-8?B?UsOkc8OkbmVu?= <tuomasjjrasanen@opinsys.fi>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>, linux-nfs@vger.kernel.org
Message-ID: <654867786.10283.1360929631448.JavaMail.root@opinsys.fi>
In-Reply-To: <CED6E6AF-B551-4099-89CE-861E5F46D31A@oracle.com>
References: <127351146.98508.1360769367943.JavaMail.root@opinsys.fi> <1117889154.119108.1360851840169.JavaMail.root@opinsys.fi> <CED6E6AF-B551-4099-89CE-861E5F46D31A@oracle.com>
Subject: Re: Kernels 3.7 and newer break rpc.gssd -n
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> From: "Chuck Lever" <chuck.lever@oracle.com>
> 
> Have you tried a kernel at commit 05f4c350 but with the compilation fix
> applied, then one with 05f4c350 removed, to confirm that this indeed is the
> commit that introduces the problem?

Yes. With commit 05f4c350 + the compilation fix, the problem occurs, but without
05f4c350, the parent (6f2ea7f) works as expected, requesting for service <null>.

> 
> When the mount operation fails, is it the first time this client attempts to
> mount a share on server.example.org, or does the client already have mounts
> of server.example.org, possibly using other security flavors?

Yes, the problem occurs on the very first mount attempt.

-- 
Tuomas
