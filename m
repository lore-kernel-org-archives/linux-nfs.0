Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:44343 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592Ab1KWCTZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Nov 2011 21:19:25 -0500
Message-ID: <4ECC5823.5060509@panasas.com>
Date: Tue, 22 Nov 2011 18:19:15 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: <bjschuma@netapp.com>
CC: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [RFC 0/4] NFS: Modularize NFS v3
References: <1322002684-20436-1-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1322002684-20436-1-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/22/2011 02:57 PM, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> This set of patches removes NFS v3 from the main NFS kernel module and creates
> a new module containing the proc, xdr, and acl code.  This will give us a
> single directory to put NFS v3 specific code so it doesn't need to be mixed in
> with the generic client stuff.
> 
> I'm sure this could still use a lot of work, but I figured I would wait to see
> what everybody thinks first.  I imagine that once we get an "nfs submodule"
> system working it'll be easier to convert v2 and v4 (and possibly v4.1?) to
> modules.
> 
> I split the second patch into two to make it easier to see what my changes were
> to get everything to compile.  Hopefully this will save some pain in having to
> look through 7000+ line patch that resulted from my `mv nfs3*.c nfs3/`
> command.  I can combine everything in a future version of the patch.
> 

If you give git format-patch the -M switch it will generate a 4 line 
"file move" annotation and will not include the full remove-and-add
patch. It will not work with old versions of patch but we all use
"git am" so you are safe.

Because we never got the 2/4 patch. It was probably too big.

I set my git tree to do the -M by default it's a git config something
something check it out.

Boaz

> Thoughts?
> 
> - Bryan
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

