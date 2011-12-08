Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44142 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405Ab1LHVKl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Dec 2011 16:10:41 -0500
Date: Thu, 8 Dec 2011 16:10:36 -0500
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: "Ted Ts'o" <tytso@mit.edu>, Eric Sandeen <sandeen@redhat.com>,
        Bernd Schubert <bernd.schubert@fastmail.fm>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        yong.fan@whamcloud.com, adilger@whamcloud.com,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: [PATCH 0/4] 32/64 bit llseek hashes (v4)
Message-ID: <20111208211036.GE32505@fieldses.org>
References: <20110817095717.1879649.41075.stgit@fsdevel3>
 <4E5D6058.8040805@fastmail.fm>
 <4EBA9551.4000404@redhat.com>
 <4EE0FF93.9060907@itwm.fraunhofer.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EE0FF93.9060907@itwm.fraunhofer.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 08, 2011 at 07:18:59PM +0100, Bernd Schubert wrote:
> Ted,
> 
> is there anything I can do to get those patched into 3.3?
> The patches still apply in current linux-git.

They appear to solve a real problem for nfsd.  What's holding them up?

--b.
