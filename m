From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: Re: [NFS] Disabling Symbolic Link Content Caching in NFS Client
Date: Tue, 3 Jun 2003 16:46:56 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030603144656.GA6157@iapetus.localdomain>
References: <CFCD2C778CF1D611B5B400065B04D5C84A736F@KENTON>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Edward Hibbert <EH@dataconnection.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
In-Reply-To: <CFCD2C778CF1D611B5B400065B04D5C84A736F@KENTON>
List-ID: <nfs.lists.sourceforge.net>

On Tue, Jun 03, 2003 at 02:33:45PM +0100, Edward Hibbert wrote:
> 
> Our application consists of a number of machines collaborating on a shared
> database over NFS.  We therefore require the ability to force data to be
> sync'd from the client to the backend - and at the moment we do this by
> disabling caching completely, via the noac option and acquiring and
> releasing non-exclusive locks round io calls.
> 
> Any improvements in the granularity of control over NFS client-side caching
> would be very valuable to us.

To disable ac for a single directory for a certain amount of time, see

	http://web.inter.nl.net/users/fvm/nfs-noac/2.4.20-noac-timeout.patch
	http://web.inter.nl.net/users/fvm/nfs-noac/readme:

This patch implements /proc/sys/net/nfs/noac-timeout

When a nonzero value is written, suspend atribute caching for the current
working directory and one level of files inside for the specified number
of seconds. Attribute caching will automatically be enabled when the time
elapses. Writing a zero re-enables attribute caching as well. Reading
yields the number of remaining seconds attribute caching will be disabled.


Maybe an NFS specific ioctl would be cleaner. But the above patch can be
used even from simple scripts.

-- 
Frank
