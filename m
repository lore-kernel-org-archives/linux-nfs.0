From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Thu, 17 Jan 2008 11:21:52 -0500
Message-ID: <20080117162152.GF16581@fieldses.org>
References: <20080110075959.GA9623@infradead.org> <4788665B.4020405@redhat.com> <18315.62909.330258.83038@notabene.brown> <478D14C5.1000804@redhat.com> <18317.7319.443532.62244@notabene.brown> <478D3820.9080402@redhat.com> <20080117151007.GB16581@fieldses.org> <478F78E8.40601@redhat.com> <20080117161415.GE16581@fieldses.org> <478F7F84.4040909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45382 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752337AbYAQQWU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jan 2008 11:22:20 -0500
In-Reply-To: <478F7F84.4040909@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 17, 2008 at 11:17:08AM -0500, Wendy Cheng wrote:
> J. Bruce Fields wrote:
>> Yeah, sounds good.  Maybe under Documentation/filesystems?  And it might
>> also be helpful to leave a reference to it in the code, e.g., in
>> nfsctl.c:
>>
>> 	/*
>> 	 * The following are used for failover; see
>> 	 * Documentation/filesystems/nfsd-failover.txt for details.
>> 	 */
>>
>> --b.
>>   
>
> ok, looks good ... but let's "fix" this on the resume patch ? or you  
> want it on the unlock patch *now* ?

It's not urgent.

--b.
