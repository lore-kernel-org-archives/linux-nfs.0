Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:47023 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738Ab2LAVkG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2012 16:40:06 -0500
Date: Sat, 1 Dec 2012 21:40:00 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Patrick McLean <patrick@cim.mcgill.ca>,
        Patrick McLean <patrickm@gaikai.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Regression with initramfs and nfsroot (appears to be in the
 dcache)
Message-ID: <20121201213959.GJ4939@ZenIV.linux.org.uk>
References: <20121129222109.GW4939@ZenIV.linux.org.uk>
 <50B7E759.9070007@gaikai.com>
 <20121129234326.GX4939@ZenIV.linux.org.uk>
 <50B7FBA7.2030300@gaikai.com>
 <20121130003502.GY4939@ZenIV.linux.org.uk>
 <50B8046F.7030308@cim.mcgill.ca>
 <20121130013628.GZ4939@ZenIV.linux.org.uk>
 <50B811BA.6070503@cim.mcgill.ca>
 <20121130020047.GA4939@ZenIV.linux.org.uk>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90B32EECB@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90B32EECB@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 30, 2012 at 01:58:18PM +0000, Myklebust, Trond wrote:

> The reason for the choice of d_drop over d_invalidate() is the d_count
> checks. It really doesn't matter whether or not the client thinks it has
> users for a directory if the server is telling you that it is ESTALE. So
> we force a d_drop to prevent further lookups from finding it.
> 
> IOW: It is there in order to fix the case where the user does
> 'rmdir("foo"); mkdir("foo")' on the server.

You do realize that your have_submounts() check in there is inherently
racy, right?
