From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: can't modify /etc/exports without blowing away existing clients
Date: Tue, 17 Feb 2009 12:14:04 -0500
Message-ID: <20090217171404.GB9489@fieldses.org>
References: <200902161220.20474.jzb2@aexorsyst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "John Z. Bohach" <jzb2-t97x8lR6yknby3iVrkZq2A@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:35803 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752999AbZBQROH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Feb 2009 12:14:07 -0500
In-Reply-To: <200902161220.20474.jzb2-t97x8lR6yknby3iVrkZq2A@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 16, 2009 at 12:20:20PM -0800, John Z. Bohach wrote:
> Hello,
> 
> When I modify /etc/exports and re-run exportfs -a -r, newly 
> added/removed/modified entries take effect, EXCEPT that all existing 
> clients lose their current mounts.  Existing clients have to umount 
> then mount NFS filesystems that were not even modified.
> 
> Is this intentional behavior?

No, that shouldn't happen.  As trond says, check whether you have the
"nfsd" filesystem mounted.

> If I try to manually add a new directory 
> for export, and just use "exportfs -i ..." and specify the new 
> directory to export that way, all existing entries in /etc/exports are 
> gratuitously UNexported, all clients lose their current mounts, and 
> only the one entry specified via the command line of "exportfs -i ..." 
> is exported.  This doesn't seem like intentional behavior?  Or is it 
> just the exportfs program that's broken?

I didn't know -i; looking at the man page, I think that's may be what's
intended.  (I haven't looked at the code.)  Why not just drop the "-i"?

--b.

> I'm running linux-2.6.24.4 and using exportfs from nfs-utils-1.1.3 
> though I've noticed this behavior on older versions of both.
> 
> Is there some NFS option I'm supposed to use in /etc/fstab on the 
> clients to keep this remount thing from being necessary?  I'm pretty 
> sure I tried both soft and hard mounts.  I'm currently using TCP as the 
> mount transport layer...would UDP fix this issue, I haven't tested 
> that...either way, even with TCP, it would be a big blow against using 
> TCP as the mount transport if umount/mount sequence was required on the 
> clients everytime time the server re-ran exportfs, which is what is 
> happening now.
> 
> Anybody know what's going on?
> 
> Thanks,
> 
> John
> 
> P.S.:  Please keep me in the CC list, I'm not subscribed to the list.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
