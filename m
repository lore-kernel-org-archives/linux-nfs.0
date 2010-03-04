Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Thu, 4 Mar 2010 09:33:18 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Matt Bernstein <+systems.extlists.nfsv4@dcs.qmul.ac.uk>
Subject: Re: Turning off delegations in NFSv4 server?
Message-ID: <20100304143317.GA17191@fieldses.org>
References: <4786788D.6040707@garzik.org> <20080110200034.GI2132@fieldses.org>
	<alpine.LRH.2.00.1003040915110.23376@frank.dcs.qmul.ac.uk>
In-Reply-To: <alpine.LRH.2.00.1003040915110.23376@frank.dcs.qmul.ac.uk>
Cc: NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 04, 2010 at 09:23:26AM +0000, Matt Bernstein wrote:
> On Jan 10 2008 J. Bruce Fields wrote:
>> On Thu, Jan 10, 2008 at 02:57:01PM -0500, Jeff Garzik wrote:
>>> Besides hacking the code, is there an easy way to turn off NFSv4
>>> delegations in the kernel v4 server?
>>>
>>> I'd like to observe behavior of the Linux v4 client when delegations are
>>> not available.
>>
>> The easiest thing is probably just to turn off leases:
>> 	echo 0 >/proc/sys/fs/leases-enable
>
> I found this from two years ago, and am wondering
> - is this still the easiest thing to do?
> - is this on server, client or both?
> - will it break anything else?
>
> We have a CentOS 5.4 NFS3/NFS4/samba server with about 300 clients on its 
> subnet, and another 100-200 on another subnet, which under high load has  
> started kernel-panicking (sometimes in nfsd4_cb_recall).

Have you filed a bug with the backtraces?

> I want to disable delegations to see if that cures our symptoms--but I  
> worry that turning leases off might cause other problems.

No, it shouldn't cause problems, at least for NFSv4 clients.  (Samba may
be more reliant on leases, especially if Samba and NFSv4 clients are
acting on the same files at the same time--but I don't know.)

--b.

>
> For now I'll probably do it anyway, given that status quo isn't stable :(
>
> Matt
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
