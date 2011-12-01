Return-Path: linux-nfs-owner@vger.kernel.org
Received: from frankvm.xs4all.nl ([83.163.148.79]:60704 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755630Ab1LARaj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 12:30:39 -0500
Date: Thu, 1 Dec 2011 18:24:16 +0100
From: Frank van Maarseveen <frankvm@frankvm.com>
To: Pavel A <free.lan.c2.718r@gmail.com>
Cc: linux-nfs@vger.kernel.org, wcheng@redhat.com, neilb@suse.de,
        jlayton@redhat.com
Subject: Re: NFS - lock failover
Message-ID: <20111201172415.GA27626@janus>
References: <CAA-yEOJ+5NssoCOAXzeCNOCkbbACn0qHrj-BtmMRYwxZFDZgxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAA-yEOJ+5NssoCOAXzeCNOCkbbACn0qHrj-BtmMRYwxZFDZgxg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 01, 2011 at 07:07:22PM +0200, Pavel A wrote:
> Hi everyone!
> 
> I was trying not to create new topics, but it seems that posting to an
> old one doesn't bring it up. Here is the original topic I'm referring
> to: http://comments.gmane.org/gmane.linux.nfs/13108
> 
> I'm building an A/A cluster using NFS v3 and local file systems, and
> looking for
> efficient ways for failover (for now I have to restart nfs-kernel-server on
> Takeover node to be able to initiate grace period), so the discussed solutions
> are very interesting to me.
> 
> Now (4 years after) in current nfs-utils packages (v. 1.2.2-4 and later) I can
> see that the ability to release locks was really implemented and is
> working well
> (I mean interfaces /proc/fs/nfsd/unlock_ip and
> /proc/fs/nfsd/unlock_filesystem),
> but how about reacquiring locks on the node, share migrates to? - I've been
> going through various mailing lists and found a lot of discussions on the topic
> (also dated mainly 2007), but don't seem to find any rpc-based mechanism or
> interface like /proc/fs/nfsd/nlm_set_grace to do that, was it ever made?

I've posted a patch some time ago implementing
/proc/fs/nfsd/relock_filesystem:

	http://permalink.gmane.org/gmane.linux.nfs/42360
	http://permalink.gmane.org/gmane.linux.nfs/42361
	http://permalink.gmane.org/gmane.linux.nfs/42362

-- 
Frank
