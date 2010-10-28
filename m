Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:16985 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab0J1S7z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 14:59:55 -0400
Subject: Re: [PATCH 6/6] nfs(5): Document remount behavior
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CC9BAA8.5000509@RedHat.com>
Date: Thu, 28 Oct 2010 14:58:53 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <BFCEEA71-05CB-4D4F-9ED8-64B140E20D2C@oracle.com>
References: <20101026155216.19184.36979.stgit@matisse.1015granger.net> <20101026155847.19184.44036.stgit@matisse.1015granger.net> <4CC9BAA8.5000509@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Oct 28, 2010, at 2:02 PM, Steve Dickson wrote:

> Chuck,
> 
> I'm a bit concern about this patch.... 
> 
> I'm asking myself who is going care how remounts update 
> /etc/mtab and what mode is used.

Someone who has done a remount and found that it doesn't behave as they expect.  I've handled bug reports like this.  When customers want to see existing documentation of strange behavior, it's pretty important to have something to point them to.  Documentation is the first thing I'm asked for by customers and system engineers who encounter weird NFS behavior.

> I just thinking that type of info 
> adds a lot verbiage that nobody really care about.

Don't you think that's a bit harsh and even disrespectful?  What criteria do you use to decide that "no-one cares"?

This patch documents very confusing behavior that is not documented anywhere else.  It's not documented elsewhere because other file systems don't have a dependency on /etc/mtab as we have.  This also documents why replacing /etc/mtab with /proc/mounts will cause some fuzzy NFS umount behavior (which is exactly the documentation you were looking for last week).

The fact that it took me so long to figure out is evidence enough that this is not obvious and needs to be written down somewhere.  Where else should we document behavior that is related to /etc/fstab and mount(8), and is NFS specific?

> Plus why are
> we documenting something (/etc/mtab) that will be going 
> away as soon as humanly possible? 

Do you have a schedule for this?  I've talked very recently with Karel, and libmount is not even ready to be published.  The work to integrate libmount into every mount subcommand sounds like it could be a ways in the future.  (Karel and I even discussed me doing this work for mount.nfs).

I expect we will have a dependence on /etc/mtab for a while yet.  And, it's pretty easy to change these docs once we've transitioned.

> Basically I'm saying the entire "Unmounting after a remount" 
> section is not needed. Only the 3 paragraphs in "THE REMOUNT OPTION"
> section are needed IMHO... 


I'll consider recrafting it, but this is important and confusing behavior that must be documented.  We can argue about how the information is presented, but just throwing it all out and ignoring it is not an option.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




