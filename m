From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Fix NLM reference count panic
Date: Sat, 5 Jan 2008 12:36:03 -0500
Message-ID: <20080105173602.GB12928@fieldses.org>
References: <477EB7D1.9030303@redhat.com> <20080104232422.GF14827@fieldses.org> <477F0F8B.9020706@redhat.com> <20080105060509.GA29020@fieldses.org> <477FC26D.5010505@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:55066 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755056AbYAERgE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Jan 2008 12:36:04 -0500
In-Reply-To: <477FC26D.5010505@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 05, 2008 at 12:46:21PM -0500, Wendy Cheng wrote:
> Actually the *existing* logic (implying without my changes) is awkward. It 
> uses file->f_locks to carry the result of unlock operation. Leave the 
> non-zero f_locks value hanging there if unlock fails, It only resets it 
> back to zero when next time nlm_inspect_file is called. Code like this is a 
> good place to generate subtle race conditions that could result with file 
> close failure. Just a complaint - I don't have a solid proof that it has 
> caused troubles though.

Absolutely agreed.  It looks very fragile to me.

--b.
