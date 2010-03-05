From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Turning off delegations in NFSv4 server?
Date: Fri, 5 Mar 2010 10:30:30 -0500
Message-ID: <20100305153030.GA14862@fieldses.org>
References: <4786788D.6040707@garzik.org> <20080110200034.GI2132@fieldses.org>
	<alpine.LRH.2.00.1003040915110.23376@frank.dcs.qmul.ac.uk>
	<20100304143317.GA17191@fieldses.org>
	<alpine.LRH.2.00.1003051239050.23376@frank.dcs.qmul.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	Matt Bernstein <mb/nfs4@eecs.qmul.ac.uk>
To: Matt Bernstein <+systems.extlists.nfsv4@dcs.qmul.ac.uk>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <alpine.LRH.2.00.1003051239050.23376@frank.dcs.qmul.ac.uk>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 05, 2010 at 03:12:46PM +0000, Matt Bernstein wrote:
> On Mar 4 J. Bruce Fields wrote:
>> On Thu, Mar 04, 2010 at 09:23:26AM +0000, Matt Bernstein wrote:
>>> On Jan 10 2008 J. Bruce Fields wrote:
>>>> The easiest thing is probably just to turn off leases:
>>>> 	echo 0 >/proc/sys/fs/leases-enable
>>>
>>> I found this from two years ago, and am wondering
>>> - is this still the easiest thing to do?
>>> - is this on server, client or both?
>>> - will it break anything else?
>>>
>>> We have a CentOS 5.4 NFS3/NFS4/samba server with about 300 clients on its
>>> subnet, and another 100-200 on another subnet, which under high load has
>>> started kernel-panicking (sometimes in nfsd4_cb_recall).
>>
>> Have you filed a bug with the backtraces?
>
> Duly nudged. I've posted the most recent one to  
> <http://bugs.centos.org/view.php?id=4229>.

OK, thanks.  Unfortunately that code has changed quite a bit since
2.6.18.  I don't recall this specific bug, but I wouldn't be suprised if
it's something we've since fixed.  Looking through 'gitk v2.6.18..
fs/nfsd/nfs4callback.c fs/nfsd/nfs4state.c' for delegation/callback
fixes might be one approach.

--b.

>
>>> I want to disable delegations to see if that cures our symptoms--but I
>>> worry that turning leases off might cause other problems.
>>
>> No, it shouldn't cause problems, at least for NFSv4 clients.  (Samba may
>> be more reliant on leases, especially if Samba and NFSv4 clients are
>> acting on the same files at the same time--but I don't know.)
>
> Thanks; no-one's grumbled just yet.
>
> Matt
