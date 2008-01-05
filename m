From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] Intro: convert lockd to kthread and fix
	use-after-free (try #3)
Date: Sat, 5 Jan 2008 11:44:03 -0500
Message-ID: <20080105164403.GA12928@fieldses.org>
References: <1198009182-27895-1-git-send-email-jlayton@redhat.com> <Pine.BSO.4.63.0712192004140.3875@rudy.mif.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org, linux-kernel@vger.kernel.org,
	richterd@citi.umich.edu
To: Tomasz =?utf-8?Q?K=C5=82oczko?= <kloczek-HJEY2/a9Cdz90TmaoATp/9Ui29CwQgaX@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36307 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755449AbYAEQoa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Jan 2008 11:44:30 -0500
In-Reply-To: <Pine.BSO.4.63.0712192004140.3875-HJEY2/a9Cdz90TmaoATp/9Ui29CwQgaX@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 19, 2007 at 08:15:43PM +0100, Tomasz K=C5=82oczko wrote:
> On Tue, 18 Dec 2007, Jeff Layton wrote:
>
>> This is the third patchset to fix the use-after-free problem in lock=
d,
>> and to convert lockd to use the kthread API instead of kernel_thread=
=2E
>> The main change from the last patchset is the elimination of the
>> svc_create_kthread helper function, and having lockd_up call kthread=
_run
>> directly. I've also made some changes to the function prototype for
>> the lockd function to eliminate the need for casting the function
>> pointer.
>
> BTW kernel, NFS and lockd: SuSE kernel IIRC is distributed with patch=
 which=20
> adds kernel-based status monitor (statd).
>
> Q to NFS people: any plans about merge this in main kernel tree ?

No.  There was opposition to the idea.  I can't remember the argument,
though, and a quick google search isn't turning it up.

> And another question related to NFS: any progress on add clear NFS=20
> statistics in kernel (nfsstat -z) ?

No.  We do have some patches that add roughly equivalent functionality
in userspace.

--b.
