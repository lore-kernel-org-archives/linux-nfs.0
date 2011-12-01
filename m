Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21352 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753527Ab1LAVFF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 16:05:05 -0500
Message-ID: <4ED7EBFF.6030706@RedHat.com>
Date: Thu, 01 Dec 2011 16:05:03 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: bjschuma@netapp.com
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC 0/4] NFS: Modularize NFS v3
References: <1322758102-29260-1-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1322758102-29260-1-git-send-email-bjschuma@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/01/2011 11:48 AM, bjschuma@netapp.com wrote:
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
> v2:
>   - I set the "diff.renames copy" git config option to create a smaller second
>     patch.  Maybe this time it won't get me kicked off the mailing list...
>     Thanks to Boaz and Jim for the tip!
> 
> Thoughts?
Now what is the motivating reason behind this re-architecture
other than making the upstream kernel literally impossible to 
back port to older kernels?? 

steved.
