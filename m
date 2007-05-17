From: Roger Heflin <rheflin@atipa.com>
Subject: Re: Apparent Deadlock with nfsd/jfs on 2.6.21.1 under bonnie.
Date: Thu, 17 May 2007 09:37:20 -0500
Message-ID: <464C68A0.2050003@atipa.com>
References: <4649BED9.6090207@atipa.com> <pan.2007.05.15.22.03.07.359081@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757924AbXEQOhc@vger.kernel.org>
In-Reply-To: <pan.2007.05.15.22.03.07.359081@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Dave Kleikamp wrote:

> 
> I don't have an answer to an ext3 deadlock, but this looks like a jfs
> problem that was recently fixed in linux-2.6.22-rc1.  I had intended to
> send it to the stable kernel after it was picked up in mainline, but
> hadn't gotten to it yet.
> 
> The patch is here:
> http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=05ec9e26be1f668ccba4ca54d9a4966c6208c611
> 

Dave,

That appears to have fixed the JFS hangup.

MTBF before was about 1 hour, under the same test I am over 20 hours
and things appear to still be holding together.

                             Roger
