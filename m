Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:47258 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab3GDEUv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jul 2013 00:20:51 -0400
Date: Thu, 4 Jul 2013 05:20:34 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Waiman Long <Waiman.Long@hp.com>
Cc: Jeff Layton <jlayton@redhat.com>, Miklos Szeredi <mszeredi@suse.cz>,
        Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Andi Kleen <andi@firstfloor.org>,
        "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>
Subject: Re: [PATCH v3 24/25] sunrpc: Change how dentry's d_lock field is
 accessed
Message-ID: <20130704042034.GM4165@ZenIV.linux.org.uk>
References: <1372883132-23410-1-git-send-email-Waiman.Long@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1372883132-23410-1-git-send-email-Waiman.Long@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 03, 2013 at 04:25:32PM -0400, Waiman Long wrote:
> There is no change in logic and everything should just work.

> -		spin_lock(&file->f_path.dentry->d_lock);
> +		d_lock(file->f_path.dentry);
>  		if (!d_unhashed(file->f_path.dentry))
>  			clnt = RPC_I(inode)->private;
>  		if (clnt != NULL && atomic_inc_not_zero(&clnt->cl_count)) {
> -			spin_unlock(&file->f_path.dentry->d_lock);
> +			d_unlock(file->f_path.dentry);

Could somebody explain WTF is being protected here?  It's not ->private -
that gets set (and, more importantly, cleared) without ->d_lock in sight.
Trond, that seems to be your code from about three years ago (introduced
in "SUNRPC: Fix a race in rpc_info_open").  What's going on there?
