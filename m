Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:54914 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755464AbbB0Wsr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Feb 2015 17:48:47 -0500
Date: Fri, 27 Feb 2015 17:48:46 -0500
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC 00/21] Richacls
Message-ID: <20150227224846.GB8750@fieldses.org>
References: <cover.1424907511.git.agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1424907511.git.agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for this!

On Thu, Feb 26, 2015 at 12:41:21AM +0100, Andreas Gruenbacher wrote:
> At this point, I would like to ask for your feedback as to what should
> be changed before these patches can be merged, even if merging these
> patches alone doesn't make a while lot of sense.  I will follow up
> with additional pieces to the puzzle like the nfsv4 support as I get
> them into shape again.

I remember my main concern being how we collapse the ACL and mask bits
to map a richacl to an NFSv4 (or Samba) ACL.  I can't remember what the
compromise there ended up being.  I guess I'll watch for that when it
comes.

--b.
