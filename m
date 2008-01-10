From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Turning off delegations in NFSv4 server?
Date: Thu, 10 Jan 2008 15:00:34 -0500
Message-ID: <20080110200034.GI2132@fieldses.org>
References: <4786788D.6040707@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4786788D.6040707@garzik.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 10, 2008 at 02:57:01PM -0500, Jeff Garzik wrote:
> Besides hacking the code, is there an easy way to turn off NFSv4 
> delegations in the kernel v4 server?
> 
> I'd like to observe behavior of the Linux v4 client when delegations are 
> not available.

The easiest thing is probably just to turn off leases:

	echo 0 >/proc/sys/fs/leases-enable

--b.
