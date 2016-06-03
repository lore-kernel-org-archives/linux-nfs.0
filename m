Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:37154 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750696AbcFCAyT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jun 2016 20:54:19 -0400
Subject: Re: NFS/d_splice_alias breakage
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=windows-1252
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <F0790F28-A8F9-406E-8B1A-F3F3773DA28E@primarydata.com>
Date: Thu, 2 Jun 2016 20:54:06 -0400
Cc: Al Viro <viro@zeniv.linux.org.uk>, "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Message-Id: <07EDB238-7EB6-48EC-8ECF-9D5A4B0986B2@linuxhacker.ru>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru> <F0790F28-A8F9-406E-8B1A-F3F3773DA28E@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 2, 2016, at 8:44 PM, Trond Myklebust wrote:

> That would have to be a really tight race, since the code in _nfs4_open_and_get_state() currently reads:
> 
> d_drop(dentry);
> alias = d_exact_alias(dentry, state->inode);
> if (!alias)
> alias = d_splice_alias(igrab(state->inode), dentry);

We live in reality where there are no more tight races left.
1 instruction-race is now huge due to commonplace cpu-overcommitted VMs (and hyperthreading), nobody knows
when is your VM cpu going to be preempted by the host (while the other
cpus of the same VM are running ahead full steam).
Stuff that took ages to trigger again to better understand is instant now.

> IOW: something would have to be acting between the d_drop() and d_splice_alias() above…

The other CPU ;)
I checked the readdirplus theory and that's not it, there's some sort of another lookup going, this dentry we crashed on never came through nfs_prime_dcache.

> Al, I’ve been distracted by personal matters in the past 6 months. What is there to guarantee exclusion of the readdirplus dentry instantiation and the NFSv4 atomic open in the brave new world of VFS, June 2016 vintage?

Note this is not a new 2016 vintage bug. I hit this in 3.10 as well (baseline kernel from one well known enterprise vendor, only there we hit it in d_realise_unique).