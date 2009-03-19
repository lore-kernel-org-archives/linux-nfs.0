From: Steve Dickson <SteveD@redhat.com>
Subject: Re: The next step: nfsvers=4
Date: Thu, 19 Mar 2009 12:50:35 -0400
Message-ID: <49C277DB.70401@RedHat.com>
References: <49C2704F.5050303@RedHat.com>
	<7A24DF798E223B4C9864E8F92E8C93EC026043D3@SACMVEXC1-PRD.hq.netapp.com>
	<855593AD-7541-443F-BA92-491EC32FEDFB@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <855593AD-7541-443F-BA92-491EC32FEDFB@oracle.com>
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



Chuck Lever wrote:
> On Mar 19, 2009, at Mar 19, 2009, 12:34 PM, Muntz, Daniel wrote:
>>> -----Original Message-----
>>> From: Steve Dickson [mailto:SteveD@redhat.com]
>>> Sent: Thursday, March 19, 2009 9:18 AM
>>> To: linux NFS Mailing list
>>> Subject: The next step: nfsvers=4
>>>
>>> As I see it, the next step to seamlessly move to V4 as the
>>> default is to make 'mount -o nfsvers=4' actually do a v4 mount...
>>>
>>> There are two obvious place we can make this change.
>>> In the kernel and/or in the mount command...
>>>
>>> Looking at the kernel, since v3 and v4 truly two different
>>> file systems its seems a bit late for the nfs_get_sb() to all
>>> of sudden have to change file system type. Meaning when
>>> nfs_get_sb() sees the "nfsvers=4" somehow it would have to
>>> back out and call nfs4_get_sb(), which obviously is a bit hacky....
>>>
>>> Now I guess we could have one nfs_get_sb() for both v3 and v4.
>>> Where the nfs_get_sb() could peek into the options data to
>>> see which version is needed. This would also mean the mount
>>> command would always have to set a version so when the "nfsvers="
>>> options is not set, the kernel would know which version to use.
>>> Again, this feels a bit hacky as well but doable...
>>>
>>> At least to me, what seems like the best option is to have
>>> the mount.nfs binary early on intercept "nfsvers=4" option
>>> and then change the fs_type to "nfs4", which would allow
>>> everything to "trickle down" as it does today... Again to me,
>>> that seem like the least intrusive way to do it...
>>>
>>> Comments? Is there other ways?
> 
> Having the mount.nfs command translate sounds like a pretty easy thing
> to prototype.
Yes.. I agree...

> 
>> Whichever way it's done, if v4 becomes the default, don't forget to also
>> make the default behavior be that the system will fall back and try a v3
>> mount if v4 isn't available.  Otherwise you'll break a huge percentage
>> of your user base.  Of course then you also have to deal with the
>> semantics of how to specifify "only v4" vs. "try v4 first and fall
>> back".
> 
> Today, specifying vers=3 means "I want vers=3 or nothing".  Not
> specifying any version means the mount command can choose which version
> to use based on what both sides support.
> 
> If no vers= option is specified, I don't think it would be difficult for
> the text-based mount command to try a "nfs4" mount first, and if that
> fails try an "nfs" mount.
> 
> Steve, would you like me to provide a prototype mount.nfs command that
> handles this?
Well I was thinking more of lets walk before we run... meaning... lets just get the
'nfsvers=4' working and accepted. Then deal with the v4/v3/v2 fall back in the
next patch set... 

As you say... the prototype looks to be pretty easy... so let me take a crack at
it... besides... you are making some good progress with IPV6 code... I don't
think this should get in the way of that...

steved.


steved.
