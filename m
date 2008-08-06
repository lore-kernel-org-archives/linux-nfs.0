From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: (was: nfs-utils-1.1.3 released)
Date: Wed, 6 Aug 2008 17:24:45 -0400
Message-ID: <59A08B4C-43CA-44E6-830F-032A324F2679@oracle.com>
References: <488D718F.200@RedHat.com>
	<20080801131533.GN14057@debianrules.debiancolombia.org>
	<20080802172529.GC30454@fieldses.org>
	<87myjul1fk.fsf@burly.wgtn.ondioline.org>
	<20080803151022.GA31484@fieldses.org>
	<60C652E1-512E-484A-874E-01997B688505@oracle.com>
	<87d4ko5wlx.fsf@burly.wgtn.ondioline.org>
	<9692E351-7140-4AD8-99F8-C9271F54CD5F@oracle.com>
	<863alj9s8p.fsf@gere.msconsult.dk>
	<5535F9D8-CD96-4807-80B3-7FD4B3983794@oracle.com>
	<m3wsiuf1im.fsf@hammer.lioka.obninsk.ru>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Sergey Bolshakov <sbolshakov@altlinux.ru>, bcwong@cisco.com
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <m3wsiuf1im.fsf@hammer.lioka.obninsk.ru>
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

On Aug 6, 2008, at 2:21 PM, Sergey Bolshakov wrote:
>>>>>> "Chuck" == Chuck Lever <chuck.lever@oracle.com> writes:
> [skipped]
>
>> In addition to the debugging mentioned above, anyone encountering  
>> this
>> regression can also try a git bisect on nfs-utils (between 1.1.2 and
>> 1.1.3).
>
> I've seen same thing with degraded sec=none having SUSE 9SP3
> nfs-utils-1.0.6-103.23 on server side and 1.1.2-3899db6d
> on client side, so 3c1bb23c seems causing problems.

That's plausible.  The patch description claims the new client  
shouldn't choose AUTH_NULL even if it's in the list, so there may be a  
bug in the logic introduced by 3c1bb23c.

The new nfs(5) man page says sec=sys is the default if no security  
flavor is explicitly specified.  This is incorrect (or an  
oversimplification at the very least), given the security negotiation  
that goes on in mount.nfs.  That's another bug that should be fixed  
when this problem is addressed.

I doubt similar security flavor negotiation occurs in the kernel's  
mountd client, in the text-based case; thus the default sec=sys is  
always used when no security flavor is specified.  That's probably yet  
another bug.

I'm still at a loss to explain how this would show up on 2.6.26  
clients.  mount.nfs from nfs-utils-1.1.1 and beyond on that kernel  
should be using the text-based interface, so changing nfs-utils  
shouldn't have any effect on this behavior.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
