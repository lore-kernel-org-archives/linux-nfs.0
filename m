Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:57335 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755747Ab2K3ELG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 23:11:06 -0500
Date: Fri, 30 Nov 2012 04:11:03 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Patrick McLean <patrickm@gaikai.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: Regression with initramfs and nfsroot (appears to be in the
 dcache)
Message-ID: <20121130041103.GF4939@ZenIV.linux.org.uk>
References: <20121129222109.GW4939@ZenIV.linux.org.uk>
 <50B7E759.9070007@gaikai.com>
 <20121129234326.GX4939@ZenIV.linux.org.uk>
 <50B7FBA7.2030300@gaikai.com>
 <20121130003502.GY4939@ZenIV.linux.org.uk>
 <50B8046F.7030308@cim.mcgill.ca>
 <20121130013628.GZ4939@ZenIV.linux.org.uk>
 <50B811BA.6070503@cim.mcgill.ca>
 <20121130020047.GA4939@ZenIV.linux.org.uk>
 <50B81B11.7050704@gaikai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50B81B11.7050704@gaikai.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 29, 2012 at 06:33:53PM -0800, Patrick McLean wrote:

> Excellent, thanks. Is there any chance this will make it to 3.7? Also we might want to cc stable@ on this as well since it is a regression in 3.6.

Definitely.  I've dropped that into vfs.git#for-linus and vfs.git#for-next
and tomorrow to Linus it goes...
